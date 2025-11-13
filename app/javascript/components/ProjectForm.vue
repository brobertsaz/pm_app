<template>
  <v-app>
    <v-container>
      <v-row>
        <v-col cols="12" md="8" offset-md="2">
          <v-card>
            <v-card-title>
              <span class="text-h5">{{ isEditMode ? 'Edit Project' : 'New Project' }}</span>
            </v-card-title>

            <v-card-text>
              <v-form ref="formRef" v-model="valid">
                <v-text-field
                  v-model="project.name"
                  label="Project Name"
                  :rules="[rules.required]"
                  required
                  prepend-icon="mdi-folder"
                ></v-text-field>

                <v-textarea
                  v-model="project.description"
                  label="Description"
                  :rules="[rules.required]"
                  rows="4"
                  prepend-icon="mdi-text"
                ></v-textarea>

                <v-select
                  v-model="project.status"
                  :items="statusOptions"
                  label="Status"
                  :rules="[rules.required]"
                  prepend-icon="mdi-flag"
                ></v-select>

                <v-select
                  v-model="project.priority"
                  :items="priorityOptions"
                  label="Priority"
                  :rules="[rules.required]"
                  prepend-icon="mdi-priority-high"
                ></v-select>

                <v-text-field
                  v-model="project.due_date"
                  label="Due Date"
                  type="date"
                  prepend-icon="mdi-calendar"
                ></v-text-field>
              </v-form>
            </v-card-text>

            <v-card-actions>
              <v-btn text @click="goBack">Cancel</v-btn>
              <v-spacer></v-spacer>
              <v-btn
                color="primary"
                :loading="loading"
                :disabled="!valid"
                @click="submitForm"
              >
                {{ isEditMode ? 'Update' : 'Create' }}
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
  projectId: {
    type: Number,
    default: null
  }
})

const formRef = ref(null)
const valid = ref(false)
const loading = ref(false)
const isEditMode = ref(false)

const project = reactive({
  name: '',
  description: '',
  status: 'Not Started',
  priority: 'Medium',
  due_date: null
})

const statusOptions = ['Not Started', 'In Progress', 'Completed', 'On Hold']
const priorityOptions = ['Low', 'Medium', 'High']

const rules = {
  required: value => !!value || 'This field is required'
}

const fetchProject = async () => {
  if (!props.projectId) return

  loading.value = true
  try {
    const response = await axios.get(`/api/v1/projects/${props.projectId}`)
    Object.assign(project, response.data)
    isEditMode.value = true
  } catch (error) {
    console.error('Error fetching project:', error)
  } finally {
    loading.value = false
  }
}

const submitForm = async () => {
  const { valid: isValid } = await formRef.value.validate()
  if (!isValid) return

  loading.value = true
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const config = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    if (isEditMode.value) {
      await axios.put(`/api/v1/projects/${props.projectId}`, { project }, config)
    } else {
      await axios.post('/api/v1/projects', { project }, config)
    }

    window.location.href = '/projects'
  } catch (error) {
    console.error('Error saving project:', error)
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  window.location.href = '/projects'
}

onMounted(() => {
  if (props.projectId) {
    fetchProject()
  }
})
</script>
