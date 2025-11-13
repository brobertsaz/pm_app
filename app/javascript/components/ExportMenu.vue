<template>
  <div class="export-menu">
    <v-menu>
      <template #activator="{ props }">
        <v-btn
          v-bind="props"
          :color="color"
          :icon="icon"
          variant="outlined"
          :prepend-icon="prependIcon"
          :size="size"
        >
          {{ label }}
        </v-btn>
      </template>

      <v-list>
        <v-list-subheader>Export Options</v-list-subheader>
        <v-divider></v-divider>

        <v-list-item v-if="showProjectOptions">
          <v-list-item-title class="text-subtitle-2 font-weight-bold">Projects</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-if="showProjectOptions"
          @click="exportProjectsCSV"
          :disabled="exporting"
        >
          <v-icon icon="mdi-file-csv" start></v-icon>
          <v-list-item-title>Projects as CSV</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-if="showProjectOptions"
          @click="exportProjectPDF"
          :disabled="exporting || !projectId"
        >
          <v-icon icon="mdi-file-pdf" start></v-icon>
          <v-list-item-title>{{ projectId ? 'Project Details as PDF' : 'Select a project' }}</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-if="showProjectOptions"
          @click="exportProjectReport"
          :disabled="exporting || !projectId"
        >
          <v-icon icon="mdi-file-pdf" start></v-icon>
          <v-list-item-title>{{ projectId ? 'Project Report as PDF' : 'Select a project' }}</v-list-item-title>
        </v-list-item>

        <v-divider v-if="showProjectOptions" class="my-2"></v-divider>

        <v-list-item v-if="showTaskOptions">
          <v-list-item-title class="text-subtitle-2 font-weight-bold">Tasks</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-if="showTaskOptions"
          @click="exportTasksCSV"
          :disabled="exporting"
        >
          <v-icon icon="mdi-file-csv" start></v-icon>
          <v-list-item-title>Tasks as CSV</v-list-item-title>
        </v-list-item>

        <v-divider v-if="showTaskOptions" class="my-2"></v-divider>

        <v-list-item v-if="showTimeEntryOptions">
          <v-list-item-title class="text-subtitle-2 font-weight-bold">Time Tracking</v-list-item-title>
        </v-list-item>
        <v-list-item
          v-if="showTimeEntryOptions"
          @click="exportTimeEntriesCSV"
          :disabled="exporting"
        >
          <v-icon icon="mdi-file-csv" start></v-icon>
          <v-list-item-title>Time Entries as CSV</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>

    <!-- Export Progress Snackbar -->
    <v-snackbar v-model="showSnackbar" color="success" timeout="3000">
      <v-icon icon="mdi-check-circle" class="mr-2"></v-icon>
      {{ snackbarMessage }}
    </v-snackbar>

    <!-- Export Error Snackbar -->
    <v-snackbar v-model="showErrorSnackbar" color="error" timeout="5000">
      <v-icon icon="mdi-alert-circle" class="mr-2"></v-icon>
      {{ errorMessage }}
    </v-snackbar>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const props = defineProps({
  label: {
    type: String,
    default: 'Export'
  },
  icon: {
    type: String,
    default: null
  },
  prependIcon: {
    type: String,
    default: 'mdi-download'
  },
  color: {
    type: String,
    default: 'primary'
  },
  size: {
    type: String,
    default: 'medium'
  },
  projectId: {
    type: [String, Number],
    default: null
  },
  showProjectOptions: {
    type: Boolean,
    default: true
  },
  showTaskOptions: {
    type: Boolean,
    default: true
  },
  showTimeEntryOptions: {
    type: Boolean,
    default: true
  }
})

const exporting = ref(false)
const showSnackbar = ref(false)
const showErrorSnackbar = ref(false)
const snackbarMessage = ref('')
const errorMessage = ref('')

const downloadFile = (url, filename) => {
  axios.get(url, {
    responseType: 'blob'
  }).then(response => {
    const blob = new Blob([response.data])
    const link = document.createElement('a')
    link.href = window.URL.createObjectURL(blob)
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(link.href)

    exporting.value = false
    snackbarMessage.value = 'File downloaded successfully!'
    showSnackbar.value = true
  }).catch(error => {
    exporting.value = false
    errorMessage.value = `Error exporting file: ${error.message}`
    showErrorSnackbar.value = true
  })
}

const exportProjectsCSV = () => {
  exporting.value = true
  downloadFile('/exports/projects', `projects_${new Date().getTime()}.csv`)
}

const exportProjectPDF = () => {
  if (!props.projectId) {
    errorMessage.value = 'Please select a project first'
    showErrorSnackbar.value = true
    return
  }
  exporting.value = true
  downloadFile(`/exports/projects/${props.projectId}`, `project_${props.projectId}_${new Date().getTime()}.pdf`)
}

const exportProjectReport = () => {
  if (!props.projectId) {
    errorMessage.value = 'Please select a project first'
    showErrorSnackbar.value = true
    return
  }
  exporting.value = true
  downloadFile(`/exports/project_report?project_id=${props.projectId}`, `project_report_${props.projectId}_${new Date().getTime()}.pdf`)
}

const exportTasksCSV = () => {
  exporting.value = true
  downloadFile('/exports/tasks', `tasks_${new Date().getTime()}.csv`)
}

const exportTimeEntriesCSV = () => {
  exporting.value = true
  downloadFile('/exports/time_entries', `time_entries_${new Date().getTime()}.csv`)
}
</script>

<style scoped>
.export-menu {
  display: inline-block;
}
</style>
