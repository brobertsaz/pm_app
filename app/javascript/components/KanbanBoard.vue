<template>
  <v-app>
    <v-container fluid class="kanban-container pa-6">
      <!-- Header with Project Filter and Actions -->
      <v-row class="mb-6">
        <v-col cols="12">
          <div class="d-flex justify-space-between align-center">
            <h1 class="text-h3 font-weight-bold">Kanban Board</h1>
            <div class="d-flex align-center gap-3">
              <v-select
                v-model="selectedProjectId"
                :items="projectOptions"
                label="Filter by Project"
                prepend-icon="mdi-filter"
                clearable
                style="max-width: 300px"
                @update:model-value="fetchTasks"
              ></v-select>
              <v-btn
                color="primary"
                prepend-icon="mdi-plus"
                @click="showAddTaskDialog = true"
              >
                Add Task
              </v-btn>
            </div>
          </div>
        </v-col>
      </v-row>

      <!-- Kanban Board -->
      <v-row class="kanban-board">
        <v-col
          v-for="status in statuses"
          :key="status"
          cols="12"
          md="4"
          class="kanban-column-wrapper"
        >
          <!-- Column Header -->
          <div class="column-header" :class="`status-${getStatusClass(status)}`">
            <div class="d-flex align-center justify-space-between">
              <h2 class="text-h6 font-weight-bold">{{ status }}</h2>
              <v-chip
                :color="getStatusColor(status)"
                text-color="white"
                size="small"
              >
                {{ tasksByStatus[status]?.length || 0 }}
              </v-chip>
            </div>
          </div>

          <!-- Droppable Column -->
          <div
            class="kanban-column"
            :data-status="status"
            @dragover.prevent="dragOver = status"
            @dragleave="dragOver = null"
            @drop.prevent="onDrop(status)"
            :class="{ 'drag-over': dragOver === status }"
          >
            <!-- Task Cards -->
            <transition-group
              name="flip-list"
              tag="div"
              class="tasks-container"
            >
              <v-card
                v-for="task in tasksByStatus[status]"
                :key="task.id"
                class="task-card mb-4"
                :class="{ 'priority-high': task.priority === 'High' }"
                draggable="true"
                @dragstart="onDragStart(task)"
                @dragend="onDragEnd"
              >
                <!-- Priority Indicator -->
                <div
                  v-if="task.priority"
                  class="priority-bar"
                  :class="`priority-${task.priority.toLowerCase()}`"
                ></div>

                <v-card-title class="text-subtitle1 pb-2 pt-3 px-4">
                  {{ task.title }}
                </v-card-title>

                <v-card-text class="px-4 py-2">
                  <!-- Description (truncated) -->
                  <p v-if="task.description" class="text-caption mb-3 text-grey-darken-1">
                    {{ truncateText(task.description, 80) }}
                  </p>

                  <!-- Task Meta Information -->
                  <div class="task-meta mb-3">
                    <!-- Priority Badge -->
                    <v-chip
                      v-if="task.priority"
                      :color="getPriorityColor(task.priority)"
                      size="x-small"
                      class="mr-2"
                      text-color="white"
                    >
                      {{ task.priority }}
                    </v-chip>

                    <!-- Project Badge -->
                    <v-chip
                      v-if="task.project"
                      color="info"
                      size="x-small"
                      variant="outlined"
                    >
                      {{ task.project.name }}
                    </v-chip>
                  </div>

                  <!-- Due Date -->
                  <div v-if="task.due_date" class="due-date-info">
                    <v-icon size="small" class="mr-1">mdi-calendar</v-icon>
                    <span class="text-caption" :class="{ 'text-error': isOverdue(task) }">
                      {{ formatDate(task.due_date) }}
                      <span v-if="isOverdue(task)" class="font-weight-bold"> (OVERDUE)</span>
                    </span>
                  </div>

                  <!-- Assigned User -->
                  <div v-if="task.user" class="user-info mt-2">
                    <v-icon size="small" class="mr-1">mdi-account</v-icon>
                    <span class="text-caption">{{ task.user.email }}</span>
                  </div>
                </v-card-text>

                <!-- Actions -->
                <v-card-actions class="pt-0 px-4 pb-3">
                  <v-spacer></v-spacer>
                  <v-btn
                    icon
                    size="small"
                    @click="editTask(task)"
                    class="mr-1"
                  >
                    <v-icon size="small">mdi-pencil</v-icon>
                    <v-tooltip activator="parent">Edit</v-tooltip>
                  </v-btn>
                  <v-btn
                    icon
                    size="small"
                    color="error"
                    @click="confirmDeleteTask(task)"
                  >
                    <v-icon size="small">mdi-delete</v-icon>
                    <v-tooltip activator="parent">Delete</v-tooltip>
                  </v-btn>
                </v-card-actions>
              </v-card>
            </transition-group>

            <!-- Empty State -->
            <div
              v-if="!tasksByStatus[status] || tasksByStatus[status].length === 0"
              class="empty-state"
            >
              <v-icon size="48" color="grey-lighten-1" class="mb-2">
                mdi-inbox-outline
              </v-icon>
              <p class="text-grey-lighten-1">No tasks yet</p>
            </div>

            <!-- Quick Add Button -->
            <v-btn
              block
              variant="outlined"
              color="primary"
              prepend-icon="mdi-plus"
              class="mt-4"
              @click="quickAddTask(status)"
            >
              Add Task
            </v-btn>
          </div>
        </v-col>
      </v-row>

      <!-- Add/Edit Task Dialog -->
      <v-dialog v-model="showAddTaskDialog" max-width="600px">
        <v-card>
          <v-card-title>
            {{ editingTaskId ? 'Edit Task' : 'Create New Task' }}
          </v-card-title>

          <v-card-text class="pt-6">
            <v-form ref="taskForm" @submit.prevent="saveTask">
              <!-- Project Selection (if not filtered) -->
              <v-select
                v-if="!selectedProjectId"
                v-model="form.project_id"
                :items="projectOptions"
                label="Project *"
                required
                class="mb-4"
              ></v-select>

              <!-- Task Title -->
              <v-text-field
                v-model="form.title"
                label="Task Title *"
                required
                class="mb-4"
                prepend-icon="mdi-format-text"
              ></v-text-field>

              <!-- Task Description -->
              <v-textarea
                v-model="form.description"
                label="Description"
                rows="3"
                class="mb-4"
                prepend-icon="mdi-note-text"
              ></v-textarea>

              <!-- Status -->
              <v-select
                v-model="form.status"
                :items="statuses"
                label="Status"
                class="mb-4"
                prepend-icon="mdi-list-status"
              ></v-select>

              <!-- Priority -->
              <v-select
                v-model="form.priority"
                :items="['Low', 'Medium', 'High']"
                label="Priority"
                class="mb-4"
                prepend-icon="mdi-flag"
              ></v-select>

              <!-- Due Date -->
              <v-text-field
                v-model="form.due_date"
                type="date"
                label="Due Date"
                class="mb-4"
                prepend-icon="mdi-calendar"
              ></v-text-field>
            </v-form>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="showAddTaskDialog = false">Cancel</v-btn>
            <v-btn
              color="primary"
              @click="saveTask"
              :loading="savingTask"
            >
              {{ editingTaskId ? 'Update' : 'Create' }}
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Delete Confirmation Dialog -->
      <v-dialog v-model="showDeleteDialog" max-width="400px">
        <v-card>
          <v-card-title>Delete Task?</v-card-title>
          <v-card-text>
            Are you sure you want to delete "{{ taskToDelete?.title }}"? This action cannot be undone.
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="showDeleteDialog = false">Cancel</v-btn>
            <v-btn
              color="error"
              @click="deleteTask"
              :loading="deletingTask"
            >
              Delete
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Snackbar for Notifications -->
      <v-snackbar
        v-model="snackbar.show"
        :color="snackbar.color"
        :timeout="3000"
      >
        {{ snackbar.message }}
      </v-snackbar>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { useWebSocket } from '../composables/useWebSocket'

// Reactive State
const tasks = ref([])
const projects = ref([])
const selectedProjectId = ref(null)
const statuses = ['To Do', 'In Progress', 'Done']
const loading = ref(false)
const savingTask = ref(false)
const deletingTask = ref(false)

// WebSocket state
const ws = useWebSocket()
const connectionStatus = ref('disconnected')
const taskUpdatesReceived = ref(0)

// Dialog States
const showAddTaskDialog = ref(false)
const showDeleteDialog = ref(false)

// Drag State
const draggedTask = ref(null)
const dragOver = ref(null)

// Form State
const editingTaskId = ref(null)
const taskToDelete = ref(null)
const form = ref({
  title: '',
  description: '',
  status: 'To Do',
  priority: 'Medium',
  due_date: '',
  project_id: null
})

// Snackbar State
const snackbar = ref({
  show: false,
  message: '',
  color: 'success'
})

// Computed Properties
const projectOptions = computed(() => {
  return projects.value.map(p => ({
    title: p.name,
    value: p.id
  }))
})

const tasksByStatus = computed(() => {
  const grouped = {}
  statuses.forEach(status => {
    grouped[status] = tasks.value.filter(t => (t.status || 'To Do') === status)
  })
  return grouped
})

// Methods
const fetchProjects = async () => {
  try {
    const response = await axios.get('/api/v1/projects')
    projects.value = response.data
  } catch (error) {
    showSnackbar('Error fetching projects', 'error')
    console.error('Error fetching projects:', error)
  }
}

const fetchTasks = async () => {
  loading.value = true
  try {
    let url = '/api/v1/tasks'
    if (selectedProjectId.value) {
      url = `/api/v1/projects/${selectedProjectId.value}/tasks`
    }

    const response = await axios.get(url)
    tasks.value = response.data

    // Subscribe to WebSocket updates for this project
    if (selectedProjectId.value) {
      subscribeToProjectTasks()
    }
  } catch (error) {
    showSnackbar('Error fetching tasks', 'error')
    console.error('Error fetching tasks:', error)
  } finally {
    loading.value = false
  }
}

const quickAddTask = (status) => {
  resetForm()
  form.value.status = status
  showAddTaskDialog.value = true
}

const editTask = (task) => {
  editingTaskId.value = task.id
  form.value = {
    title: task.title,
    description: task.description,
    status: task.status,
    priority: task.priority,
    due_date: task.due_date,
    project_id: task.project_id
  }
  showAddTaskDialog.value = true
}

const saveTask = async () => {
  if (!form.value.title.trim()) {
    showSnackbar('Task title is required', 'error')
    return
  }

  if (!form.value.project_id && !selectedProjectId.value) {
    showSnackbar('Please select a project', 'error')
    return
  }

  savingTask.value = true
  try {
    const projectId = form.value.project_id || selectedProjectId.value
    const payload = {
      task: {
        title: form.value.title,
        description: form.value.description,
        status: form.value.status,
        priority: form.value.priority,
        due_date: form.value.due_date
      }
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    if (editingTaskId.value) {
      // Update existing task
      await axios.put(
        `/api/v1/projects/${projectId}/tasks/${editingTaskId.value}`,
        payload,
        { headers: { 'X-CSRF-Token': csrfToken } }
      )
      showSnackbar('Task updated successfully', 'success')
    } else {
      // Create new task
      await axios.post(
        `/api/v1/projects/${projectId}/tasks`,
        payload,
        { headers: { 'X-CSRF-Token': csrfToken } }
      )
      showSnackbar('Task created successfully', 'success')
    }

    resetForm()
    showAddTaskDialog.value = false
    await fetchTasks()
  } catch (error) {
    showSnackbar('Error saving task', 'error')
    console.error('Error saving task:', error)
  } finally {
    savingTask.value = false
  }
}

const confirmDeleteTask = (task) => {
  taskToDelete.value = task
  showDeleteDialog.value = true
}

const deleteTask = async () => {
  if (!taskToDelete.value) return

  deletingTask.value = true
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    await axios.delete(
      `/api/v1/projects/${taskToDelete.value.project_id}/tasks/${taskToDelete.value.id}`,
      { headers: { 'X-CSRF-Token': csrfToken } }
    )
    showSnackbar('Task deleted successfully', 'success')
    showDeleteDialog.value = false
    taskToDelete.value = null
    await fetchTasks()
  } catch (error) {
    showSnackbar('Error deleting task', 'error')
    console.error('Error deleting task:', error)
  } finally {
    deletingTask.value = false
  }
}

// Drag and Drop Methods
const onDragStart = (task) => {
  draggedTask.value = task
}

const onDragEnd = () => {
  draggedTask.value = null
  dragOver.value = null
}

const onDrop = async (newStatus) => {
  if (!draggedTask.value || draggedTask.value.status === newStatus) {
    dragOver.value = null
    return
  }

  const taskToUpdate = draggedTask.value
  const oldStatus = taskToUpdate.status

  // Optimistic update
  taskToUpdate.status = newStatus

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    await axios.put(
      `/api/v1/projects/${taskToUpdate.project_id}/tasks/${taskToUpdate.id}`,
      {
        task: {
          status: newStatus
        }
      },
      { headers: { 'X-CSRF-Token': csrfToken } }
    )
    showSnackbar(`Task moved to ${newStatus}`, 'success')
  } catch (error) {
    // Revert on error
    taskToUpdate.status = oldStatus
    showSnackbar('Error updating task status', 'error')
    console.error('Error updating task:', error)
  }

  dragOver.value = null
}

// Utility Methods
const resetForm = () => {
  editingTaskId.value = null
  form.value = {
    title: '',
    description: '',
    status: 'To Do',
    priority: 'Medium',
    due_date: '',
    project_id: selectedProjectId.value || null
  }
}

const showSnackbar = (message, color = 'success') => {
  snackbar.value = { show: true, message, color }
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const isOverdue = (task) => {
  if (!task.due_date || task.status === 'Done') return false
  return new Date(task.due_date) < new Date()
}

const getStatusColor = (status) => {
  const colors = {
    'To Do': '#FF6B6B',
    'In Progress': '#4ECDC4',
    'Done': '#95E1D3'
  }
  return colors[status] || '#95A5A6'
}

const getPriorityColor = (priority) => {
  const colors = {
    'Low': '#2ECC71',
    'Medium': '#F39C12',
    'High': '#E74C3C'
  }
  return colors[priority] || '#95A5A6'
}

const getStatusClass = (status) => {
  const map = {
    'To Do': 'todo',
    'In Progress': 'inprogress',
    'Done': 'done'
  }
  return map[status] || 'default'
}

// WebSocket Methods
const initializeWebSocket = () => {
  // Connect to WebSocket
  ws.connect()

  // Monitor connection status
  const statusCheckInterval = setInterval(() => {
    connectionStatus.value = ws.connectionStatus.value
  }, 1000)

  return () => {
    clearInterval(statusCheckInterval)
  }
}

const subscribeToProjectTasks = () => {
  if (!selectedProjectId.value) {
    return
  }

  // Unsubscribe from previous project if any
  const previousProjectId = ref(null)
  if (previousProjectId.value && previousProjectId.value !== selectedProjectId.value) {
    ws.unsubscribe('TaskChannel', { project_id: previousProjectId.value })
  }

  // Subscribe to task updates for the selected project
  ws.subscribe('TaskChannel', { project_id: selectedProjectId.value })

  // Handle task messages
  ws.onMessage('TaskChannel', (data) => {
    console.log('Task update from WebSocket:', data)

    if (data.type === 'task_created' && data.task) {
      // Add new task to the list
      tasks.value.push(data.task)
      taskUpdatesReceived.value++
      showSnackbar(`Task "${data.task.title}" created by another user`, 'info')
    } else if (data.type === 'task_updated' && data.task) {
      // Update existing task
      const index = tasks.value.findIndex((t) => t.id === data.task.id)
      if (index > -1) {
        tasks.value[index] = data.task
        taskUpdatesReceived.value++
      }
    } else if (data.type === 'task_deleted' && data.task_id) {
      // Remove deleted task
      tasks.value = tasks.value.filter((t) => t.id !== data.task_id)
      taskUpdatesReceived.value++
      showSnackbar(`Task "${data.task_title}" was deleted`, 'info')
    } else if (data.type === 'task_status_changed' && data.task) {
      // Update task status
      const index = tasks.value.findIndex((t) => t.id === data.task.id)
      if (index > -1) {
        const oldStatus = tasks.value[index].status
        tasks.value[index] = data.task
        taskUpdatesReceived.value++
        showSnackbar(`Task moved from ${oldStatus} to ${data.new_status}`, 'info')
      }
    } else if (data.type === 'tasks_list' && data.tasks) {
      // Full task list received
      tasks.value = data.tasks
    }
  })

  previousProjectId.value = selectedProjectId.value
}

// Lifecycle
onMounted(() => {
  fetchProjects()
  fetchTasks()
  initializeWebSocket()
})

onUnmounted(() => {
  ws.disconnect()
})
</script>

<style scoped lang="scss">
.kanban-container {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

.kanban-board {
  gap: 20px;
}

.kanban-column-wrapper {
  display: flex;
  flex-direction: column;
}

.column-header {
  padding: 16px;
  border-radius: 12px 12px 0 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin-bottom: 0;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);

  &.status-todo {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF5252 100%);
  }

  &.status-inprogress {
    background: linear-gradient(135deg, #4ECDC4 0%, #44A08D 100%);
  }

  &.status-done {
    background: linear-gradient(135deg, #95E1D3 0%, #6BCB77 100%);
  }

  h2 {
    margin: 0;
    color: white;
  }
}

.kanban-column {
  background: #f8f9fa;
  border-radius: 0 0 12px 12px;
  padding: 16px;
  min-height: 400px;
  max-height: calc(100vh - 200px);
  overflow-y: auto;
  transition: all 0.3s ease;
  border: 2px dashed transparent;

  &.drag-over {
    background: #e8f4f8;
    border-color: #4ECDC4;
    box-shadow: inset 0 0 10px rgba(78, 205, 196, 0.2);
  }

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-track {
    background: #f0f0f0;
    border-radius: 10px;
  }

  &::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 10px;

    &:hover {
      background: #999;
    }
  }
}

.tasks-container {
  min-height: 50px;
}

.task-card {
  cursor: move;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-left: 4px solid transparent;
  position: relative;
  overflow: hidden;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 20px rgba(0, 0, 0, 0.15);
  }

  &.priority-high {
    border-left-color: #e74c3c;
  }

  &:active {
    opacity: 0.8;
    cursor: grabbing;
  }
}

.priority-bar {
  height: 4px;
  width: 100%;
  position: absolute;
  top: 0;
  left: 0;

  &.priority-low {
    background: #2ecc71;
  }

  &.priority-medium {
    background: #f39c12;
  }

  &.priority-high {
    background: #e74c3c;
  }
}

.task-meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.due-date-info,
.user-info {
  display: flex;
  align-items: center;
  font-size: 12px;
  color: #666;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  text-align: center;
  color: #bbb;
}

// Animations
.flip-list-move {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.flip-list-enter-active,
.flip-list-leave-active {
  transition: all 0.3s ease;
}

.flip-list-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.flip-list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

// Responsive Design
@media (max-width: 1024px) {
  .kanban-column {
    min-height: 300px;
  }
}

@media (max-width: 768px) {
  .kanban-container {
    padding: 12px !important;
  }

  .kanban-column {
    min-height: 250px;
  }

  .task-card {
    margin-bottom: 12px;
  }
}
</style>
