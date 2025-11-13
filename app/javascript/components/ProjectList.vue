<template>
  <v-app>
    <v-container>
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="d-flex justify-space-between align-center">
              <span class="text-h5">Projects</span>
              <v-btn color="primary" :to="{ name: 'new-project' }" prepend-icon="mdi-plus">
                New Project
              </v-btn>
            </v-card-title>

            <v-card-text>
              <v-text-field
                v-model="search"
                prepend-inner-icon="mdi-magnify"
                label="Search projects"
                single-line
                hide-details
                clearable
                class="mb-4"
              ></v-text-field>

              <v-data-table
                :headers="headers"
                :items="filteredProjects"
                :loading="loading"
                :items-per-page="10"
                class="elevation-1"
              >
                <template v-slot:item.status="{ item }">
                  <v-chip :color="getStatusColor(item.status)" size="small">
                    {{ item.status }}
                  </v-chip>
                </template>

                <template v-slot:item.priority="{ item }">
                  <v-chip :color="getPriorityColor(item.priority)" size="small">
                    {{ item.priority }}
                  </v-chip>
                </template>

                <template v-slot:item.created_at="{ item }">
                  {{ formatDate(item.created_at) }}
                </template>

                <template v-slot:item.actions="{ item }">
                  <v-btn icon size="small" @click="viewProject(item)" class="mr-1">
                    <v-icon>mdi-eye</v-icon>
                  </v-btn>
                  <v-btn icon size="small" @click="editProject(item)" class="mr-1">
                    <v-icon>mdi-pencil</v-icon>
                  </v-btn>
                  <v-btn icon size="small" color="error" @click="confirmDelete(item)">
                    <v-icon>mdi-delete</v-icon>
                  </v-btn>
                </template>
              </v-data-table>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Delete Confirmation Dialog -->
      <v-dialog v-model="deleteDialog" max-width="500px">
        <v-card>
          <v-card-title>Confirm Delete</v-card-title>
          <v-card-text>
            Are you sure you want to delete "{{ projectToDelete?.name }}"?
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="deleteDialog = false">Cancel</v-btn>
            <v-btn color="error" @click="deleteProject">Delete</v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const projects = ref([])
const loading = ref(false)
const search = ref('')
const deleteDialog = ref(false)
const projectToDelete = ref(null)

const headers = [
  { title: 'Name', key: 'name', sortable: true },
  { title: 'Description', key: 'description', sortable: false },
  { title: 'Status', key: 'status', sortable: true },
  { title: 'Priority', key: 'priority', sortable: true },
  { title: 'Created', key: 'created_at', sortable: true },
  { title: 'Actions', key: 'actions', sortable: false },
]

const filteredProjects = computed(() => {
  if (!search.value) return projects.value

  const searchLower = search.value.toLowerCase()
  return projects.value.filter(project =>
    project.name?.toLowerCase().includes(searchLower) ||
    project.description?.toLowerCase().includes(searchLower)
  )
})

const fetchProjects = async () => {
  loading.value = true
  try {
    const response = await axios.get('/api/v1/projects')
    projects.value = response.data
  } catch (error) {
    console.error('Error fetching projects:', error)
  } finally {
    loading.value = false
  }
}

const viewProject = (project) => {
  window.location.href = `/projects/${project.id}`
}

const editProject = (project) => {
  window.location.href = `/projects/${project.id}/edit`
}

const confirmDelete = (project) => {
  projectToDelete.value = project
  deleteDialog.value = true
}

const deleteProject = async () => {
  if (!projectToDelete.value) return

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    await axios.delete(`/api/v1/projects/${projectToDelete.value.id}`, {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    })
    projects.value = projects.value.filter(p => p.id !== projectToDelete.value.id)
    deleteDialog.value = false
    projectToDelete.value = null
  } catch (error) {
    console.error('Error deleting project:', error)
  }
}

const getStatusColor = (status) => {
  const colors = {
    'Not Started': 'grey',
    'In Progress': 'blue',
    'Completed': 'green',
    'On Hold': 'orange'
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

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString()
}

onMounted(() => {
  fetchProjects()
})
</script>
