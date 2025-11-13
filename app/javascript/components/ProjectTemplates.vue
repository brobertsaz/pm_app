<template>
  <v-app>
    <v-container>
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="d-flex justify-space-between align-center">
              <span class="text-h5">Project Templates</span>
              <div>
                <v-btn color="primary" @click="showCreateDialog = true" prepend-icon="mdi-plus" class="mr-2">
                  New Template
                </v-btn>
                <v-btn color="secondary" @click="showPublicTemplates = !showPublicTemplates" prepend-icon="mdi-globe">
                  {{ showPublicTemplates ? 'My Templates' : 'Browse Public' }}
                </v-btn>
              </div>
            </v-card-title>

            <v-card-text>
              <v-text-field
                v-model="search"
                prepend-inner-icon="mdi-magnify"
                label="Search templates"
                single-line
                hide-details
                clearable
                class="mb-4"
              ></v-text-field>

              <v-row v-if="filteredTemplates.length > 0">
                <v-col v-for="template in filteredTemplates" :key="template.id" cols="12" sm="6" md="4">
                  <v-card class="h-100">
                    <v-card-title class="text-subtitle1">{{ template.name }}</v-card-title>
                    <v-card-subtitle>
                      By {{ template.user.email }}
                      <v-chip v-if="template.is_public" size="small" color="success" class="ml-2">
                        Public
                      </v-chip>
                    </v-card-subtitle>
                    <v-card-text>
                      <p class="text-body2 mb-3">{{ template.description }}</p>
                      <div class="text-caption">
                        <strong>{{ template.template_tasks.length }} Tasks</strong>
                      </div>
                      <v-list class="mt-2" density="compact">
                        <v-list-item v-for="task in template.template_tasks.slice(0, 3)" :key="task.id" class="pl-0">
                          <template v-slot:prepend>
                            <v-chip :color="getStatusColor(task.status)" size="x-small">
                              {{ task.status }}
                            </v-chip>
                          </template>
                          <v-list-item-title class="text-caption">{{ task.title }}</v-list-item-title>
                        </v-list-item>
                        <v-list-item v-if="template.template_tasks.length > 3" class="text-caption text-disabled">
                          +{{ template.template_tasks.length - 3 }} more tasks
                        </v-list-item>
                      </v-list>
                    </v-card-text>
                    <v-card-actions>
                      <v-btn text size="small" @click="previewTemplate(template)">
                        <v-icon>mdi-eye</v-icon>
                        Preview
                      </v-btn>
                      <v-btn text size="small" @click="showInstantiateDialog(template)" color="success">
                        <v-icon>mdi-play</v-icon>
                        Use Template
                      </v-btn>
                      <v-btn v-if="template.user.id === currentUserId" text size="small" @click="editTemplate(template)">
                        <v-icon>mdi-pencil</v-icon>
                      </v-btn>
                      <v-btn v-if="template.user.id === currentUserId" text size="small" color="error" @click="confirmDelete(template)">
                        <v-icon>mdi-delete</v-icon>
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-col>
              </v-row>

              <v-alert v-else type="info" title="No Templates Found">
                {{ showPublicTemplates ? 'No public templates available' : 'Create your first template to get started' }}
              </v-alert>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Create/Edit Template Dialog -->
      <v-dialog v-model="showCreateDialog" max-width="600px">
        <v-card>
          <v-card-title>{{ editingTemplate ? 'Edit Template' : 'Create New Template' }}</v-card-title>
          <v-card-text>
            <v-text-field
              v-model="formData.name"
              label="Template Name"
              required
              class="mb-3"
            ></v-text-field>
            <v-textarea
              v-model="formData.description"
              label="Description"
              rows="3"
              class="mb-3"
            ></v-textarea>
            <v-checkbox
              v-model="formData.is_public"
              label="Make this template public"
            ></v-checkbox>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="showCreateDialog = false">Cancel</v-btn>
            <v-btn color="primary" @click="saveTemplate">{{ editingTemplate ? 'Update' : 'Create' }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Instantiate Template Dialog -->
      <v-dialog v-model="showInstantiateModal" max-width="500px">
        <v-card>
          <v-card-title>Create Project from Template</v-card-title>
          <v-card-text>
            <p class="text-body2 mb-4">
              This will create a new project with {{ instantiateTemplate?.template_tasks.length || 0 }} tasks from the selected template.
            </p>
            <v-text-field
              v-model="projectName"
              label="Project Name"
              :placeholder="instantiateTemplate?.name"
              required
            ></v-text-field>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="showInstantiateModal = false">Cancel</v-btn>
            <v-btn color="success" @click="instantiateTemplate">Create Project</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Preview Template Dialog -->
      <v-dialog v-model="showPreviewModal" max-width="700px">
        <v-card>
          <v-card-title>{{ previewData?.name }}</v-card-title>
          <v-card-subtitle>{{ previewData?.description }}</v-card-subtitle>
          <v-card-text>
            <div class="mb-4">
              <strong>Template Information:</strong>
              <v-list density="compact">
                <v-list-item>
                  <template v-slot:prepend>
                    <v-icon>mdi-briefcase</v-icon>
                  </template>
                  <v-list-item-title>{{ previewData?.template_tasks.length || 0 }} Tasks</v-list-item-title>
                </v-list-item>
                <v-list-item>
                  <template v-slot:prepend>
                    <v-icon>mdi-account</v-icon>
                  </template>
                  <v-list-item-title>Created by {{ previewData?.user.email }}</v-list-item-title>
                </v-list-item>
              </v-list>
            </div>

            <v-divider class="my-4"></v-divider>

            <div>
              <strong class="text-body2">Tasks in this template:</strong>
              <v-list v-if="previewData?.template_tasks.length > 0" class="mt-2">
                <v-list-item v-for="task in previewData.template_tasks" :key="task.id">
                  <template v-slot:prepend>
                    <v-chip :color="getStatusColor(task.status)" size="small">
                      {{ task.status }}
                    </v-chip>
                  </template>
                  <v-list-item-title>{{ task.title }}</v-list-item-title>
                  <template v-slot:append>
                    <v-chip :color="getPriorityColor(task.priority)" size="small">
                      {{ task.priority }}
                    </v-chip>
                  </template>
                </v-list-item>
              </v-list>
              <v-alert v-else type="info">No tasks in this template</v-alert>
            </div>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="showPreviewModal = false">Close</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Delete Confirmation Dialog -->
      <v-dialog v-model="deleteDialog" max-width="500px">
        <v-card>
          <v-card-title>Confirm Delete</v-card-title>
          <v-card-text>
            Are you sure you want to delete "{{ templateToDelete?.name }}"? This action cannot be undone.
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="deleteDialog = false">Cancel</v-btn>
            <v-btn color="error" @click="deleteTemplate">Delete</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const templates = ref([])
const search = ref('')
const loading = ref(false)
const showCreateDialog = ref(false)
const showInstantiateModal = ref(false)
const showPreviewModal = ref(false)
const deleteDialog = ref(false)
const showPublicTemplates = ref(false)
const currentUserId = ref(null)

const editingTemplate = ref(null)
const instantiateTemplate = ref(null)
const previewData = ref(null)
const templateToDelete = ref(null)
const projectName = ref('')

const formData = ref({
  name: '',
  description: '',
  is_public: false
})

const filteredTemplates = computed(() => {
  if (!search.value) return templates.value

  const searchLower = search.value.toLowerCase()
  return templates.value.filter(template =>
    template.name?.toLowerCase().includes(searchLower) ||
    template.description?.toLowerCase().includes(searchLower)
  )
})

const fetchTemplates = async () => {
  loading.value = true
  try {
    const url = showPublicTemplates.value
      ? '/api/v1/project_templates/public'
      : '/api/v1/project_templates'
    const response = await axios.get(url)
    templates.value = response.data
  } catch (error) {
    console.error('Error fetching templates:', error)
  } finally {
    loading.value = false
  }
}

const fetchCurrentUser = async () => {
  try {
    const response = await axios.get('/api/v1/current_user')
    currentUserId.value = response.data.id
  } catch (error) {
    console.error('Error fetching current user:', error)
  }
}

const saveTemplate = async () => {
  if (!formData.value.name || !formData.value.description) {
    alert('Please fill in all required fields')
    return
  }

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const url = editingTemplate.value
      ? `/api/v1/project_templates/${editingTemplate.value.id}`
      : '/api/v1/project_templates'
    const method = editingTemplate.value ? 'put' : 'post'

    await axios[method](url, {
      project_template: formData.value
    }, {
      headers: { 'X-CSRF-Token': csrfToken }
    })

    showCreateDialog.value = false
    editingTemplate.value = null
    formData.value = { name: '', description: '', is_public: false }
    await fetchTemplates()
  } catch (error) {
    console.error('Error saving template:', error)
    alert('Error saving template')
  }
}

const editTemplate = (template) => {
  editingTemplate.value = template
  formData.value = {
    name: template.name,
    description: template.description,
    is_public: template.is_public
  }
  showCreateDialog.value = true
}

const showInstantiateDialog = (template) => {
  instantiateTemplate.value = template
  projectName.value = ''
  showInstantiateModal.value = true
}

const instantiateTemplateProject = async () => {
  if (!instantiateTemplate.value) return

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const response = await axios.post(
      `/api/v1/project_templates/${instantiateTemplate.value.id}/instantiate`,
      {
        project_name: projectName.value || instantiateTemplate.value.name
      },
      {
        headers: { 'X-CSRF-Token': csrfToken }
      }
    )

    showInstantiateModal.value = false
    instantiateTemplate.value = null
    projectName.value = ''
    alert('Project created successfully from template!')
    window.location.href = `/projects/${response.data.project.id}`
  } catch (error) {
    console.error('Error instantiating template:', error)
    alert('Error creating project from template')
  }
}

const previewTemplate = (template) => {
  previewData.value = template
  showPreviewModal.value = true
}

const confirmDelete = (template) => {
  templateToDelete.value = template
  deleteDialog.value = true
}

const deleteTemplate = async () => {
  if (!templateToDelete.value) return

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    await axios.delete(`/api/v1/project_templates/${templateToDelete.value.id}`, {
      headers: { 'X-CSRF-Token': csrfToken }
    })

    templates.value = templates.value.filter(t => t.id !== templateToDelete.value.id)
    deleteDialog.value = false
    templateToDelete.value = null
  } catch (error) {
    console.error('Error deleting template:', error)
    alert('Error deleting template')
  }
}

const getStatusColor = (status) => {
  const colors = {
    'To Do': 'grey',
    'In Progress': 'blue',
    'Done': 'green'
  }
  return colors[status] || 'grey'
}

const getPriorityColor = (priority) => {
  const colors = {
    'Low': 'green',
    'Medium': 'orange',
    'High': 'red'
  }
  return colors[priority] || 'grey'
}

onMounted(() => {
  fetchCurrentUser()
  fetchTemplates()
})
</script>
