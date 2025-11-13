<template>
  <v-card class="file-uploader">
    <v-card-title>
      <span class="text-h6">Files</span>
      <v-spacer></v-spacer>
      <span class="text-subtitle-2 text-grey">({{ files.length }})</span>
    </v-card-title>

    <v-divider></v-divider>

    <!-- Upload Area -->
    <v-card-text class="pa-4">
      <div
        @dragover.prevent="isDragging = true"
        @dragleave.prevent="isDragging = false"
        @drop.prevent="handleDrop"
        :class="['upload-area', { 'dragging': isDragging }]"
      >
        <v-icon size="48" class="mb-2">mdi-cloud-upload-outline</v-icon>
        <p class="text-subtitle-1 mb-2">Drag and drop files here</p>
        <p class="text-caption text-grey mb-4">or</p>
        <v-btn
          color="primary"
          variant="outlined"
          @click="fileInput.click()"
          :disabled="uploading"
        >
          <v-icon start>mdi-folder-open</v-icon>
          Choose Files
        </v-btn>

        <input
          ref="fileInput"
          type="file"
          multiple
          @change="handleFileSelect"
          style="display: none"
          :disabled="uploading"
        />

        <div v-if="uploading" class="mt-4">
          <v-progress-linear
            :value="uploadProgress"
            color="primary"
          ></v-progress-linear>
          <p class="text-caption text-center mt-2">{{ uploadProgress }}%</p>
        </div>
      </div>
    </v-card-text>

    <v-divider></v-divider>

    <!-- Files List -->
    <v-card-text v-if="files.length > 0" class="files-list pa-0">
      <v-list>
        <v-list-item v-for="file in files" :key="file.id" class="file-item">
          <template #prepend>
            <v-icon :icon="getFileIcon(file.filename)" size="large"></v-icon>
          </template>

          <div class="file-info">
            <v-list-item-title class="text-truncate">
              {{ file.filename }}
            </v-list-item-title>
            <v-list-item-subtitle>
              {{ formatFileSize(file.byte_size) }} · {{ formatDate(file.created_at) }}
            </v-list-item-subtitle>
          </div>

          <template #append>
            <div class="file-actions">
              <v-btn
                icon
                size="small"
                variant="text"
                :href="getDownloadUrl(file.id)"
                target="_blank"
                title="Download"
              >
                <v-icon>mdi-download</v-icon>
              </v-btn>
              <v-btn
                icon
                size="small"
                variant="text"
                @click="deleteFile(file.id)"
                :loading="deletingFileId === file.id"
                title="Delete"
              >
                <v-icon>mdi-delete</v-icon>
              </v-btn>
            </div>
          </template>
        </v-list-item>
      </v-list>
    </v-card-text>

    <!-- Empty State -->
    <v-card-text v-else class="text-center py-8">
      <v-icon size="48" class="mb-2 opacity-50">mdi-file-outline</v-icon>
      <p class="text-subtitle-2 opacity-75">No files attached yet</p>
    </v-card-text>

    <!-- Error Message -->
    <v-snackbar
      v-model="showError"
      color="error"
      timeout="5000"
    >
      {{ errorMessage }}
    </v-snackbar>

    <!-- Success Message -->
    <v-snackbar
      v-model="showSuccess"
      color="success"
      timeout="3000"
    >
      File uploaded successfully
    </v-snackbar>
  </v-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
  attachableType: {
    type: String,
    required: true,
    validator: value => ['Project', 'Task'].includes(value)
  },
  attachableId: {
    type: Number,
    required: true
  }
})

const fileInput = ref(null)
const files = reactive([])
const isDragging = ref(false)
const uploading = ref(false)
const uploadProgress = ref(0)
const deletingFileId = ref(null)
const showError = ref(false)
const showSuccess = ref(false)
const errorMessage = ref('')

const getApiPath = () => {
  const typeMap = {
    'Project': 'projects',
    'Task': 'tasks'
  }
  return `/api/v1/${typeMap[props.attachableType]}/${props.attachableId}`
}

const getFileIcon = (filename) => {
  const ext = filename.split('.').pop().toLowerCase()
  const iconMap = {
    'pdf': 'mdi-file-pdf',
    'doc': 'mdi-file-word',
    'docx': 'mdi-file-word',
    'xls': 'mdi-file-excel',
    'xlsx': 'mdi-file-excel',
    'ppt': 'mdi-file-powerpoint',
    'pptx': 'mdi-file-powerpoint',
    'jpg': 'mdi-file-image',
    'jpeg': 'mdi-file-image',
    'png': 'mdi-file-image',
    'gif': 'mdi-file-image',
    'zip': 'mdi-file-zip',
    'rar': 'mdi-file-zip',
    'txt': 'mdi-file-document',
    'csv': 'mdi-file-csv'
  }
  return iconMap[ext] || 'mdi-file'
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i]
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const getDownloadUrl = (fileId) => {
  return `${getApiPath()}/files/${fileId}/download`
}

const handleFileSelect = (event) => {
  const selectedFiles = Array.from(event.target.files)
  uploadFiles(selectedFiles)
}

const handleDrop = (event) => {
  isDragging.value = false
  const droppedFiles = Array.from(event.dataTransfer.files)
  uploadFiles(droppedFiles)
}

const uploadFiles = async (filesToUpload) => {
  if (filesToUpload.length === 0) return

  uploading.value = true
  uploadProgress.value = 0

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    for (let i = 0; i < filesToUpload.length; i++) {
      const file = filesToUpload[i]
      const formData = new FormData()
      formData.append('files[]', file)

      try {
        const response = await axios.post(
          `${getApiPath()}/files`,
          formData,
          {
            headers: {
              'X-CSRF-Token': csrfToken,
              'Content-Type': 'multipart/form-data'
            },
            onUploadProgress: (progressEvent) => {
              const progress = Math.round(
                ((i + progressEvent.loaded / progressEvent.total) / filesToUpload.length) * 100
              )
              uploadProgress.value = progress
            }
          }
        )

        files.push(...response.data)
      } catch (error) {
        errorMessage.value = `Failed to upload ${file.name}`
        showError.value = true
        console.error('Error uploading file:', error)
      }
    }

    showSuccess.value = true
  } catch (error) {
    errorMessage.value = 'Failed to upload files'
    showError.value = true
    console.error('Error uploading files:', error)
  } finally {
    uploading.value = false
    uploadProgress.value = 0
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  }
}

const deleteFile = async (fileId) => {
  if (!confirm('Are you sure you want to delete this file?')) return

  deletingFileId.value = fileId
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const config = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    await axios.delete(
      `${getApiPath()}/files/${fileId}`,
      config
    )

    const index = files.findIndex(f => f.id === fileId)
    if (index > -1) {
      files.splice(index, 1)
    }

    showSuccess.value = true
  } catch (error) {
    errorMessage.value = 'Failed to delete file'
    showError.value = true
    console.error('Error deleting file:', error)
  } finally {
    deletingFileId.value = null
  }
}

const fetchFiles = async () => {
  try {
    const response = await axios.get(`${getApiPath()}/files`)
    files.length = 0
    files.push(...response.data)
  } catch (error) {
    console.error('Error fetching files:', error)
  }
}

onMounted(() => {
  fetchFiles()
})
</script>

<style scoped>
.file-uploader {
  margin-bottom: 24px;
}

.upload-area {
  border: 2px dashed #bdbdbd;
  border-radius: 8px;
  padding: 40px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background-color: rgba(0, 0, 0, 0.02);

  &:hover {
    border-color: #1976d2;
    background-color: rgba(25, 118, 210, 0.05);
  }

  &.dragging {
    border-color: #1976d2;
    background-color: rgba(25, 118, 210, 0.1);
    box-shadow: inset 0 0 0 2px #1976d2;
  }
}

.files-list {
  background-color: rgba(0, 0, 0, 0.02);
}

.file-item {
  padding: 12px 16px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);

  &:hover {
    background-color: rgba(0, 0, 0, 0.04);
  }

  &:last-child {
    border-bottom: none;
  }
}

.file-info {
  flex: 1;
  overflow: hidden;
  padding: 0 16px;
}

.file-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s;
}

.file-item:hover .file-actions {
  opacity: 1;
}

.opacity-50 {
  opacity: 0.5;
}

.opacity-75 {
  opacity: 0.75;
}
</style>
