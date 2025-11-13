<template>
  <v-app>
    <v-container fluid class="py-6">
      <!-- Header -->
      <v-row>
        <v-col cols="12">
          <div class="d-flex justify-space-between align-center mb-6">
            <h1 class="text-h4 font-weight-bold">Dashboard</h1>
            <div class="d-flex gap-3">
              <v-btn
                color="primary"
                prepend-icon="mdi-plus"
                @click="navigateToNewProject"
              >
                New Project
              </v-btn>
              <v-btn
                color="accent"
                prepend-icon="mdi-plus"
                @click="navigateToNewTask"
              >
                New Task
              </v-btn>
            </div>
          </div>
        </v-col>
      </v-row>

      <!-- Statistics Cards -->
      <v-row class="mb-6">
        <v-col cols="12" sm="6" md="3">
          <v-card class="h-100 gradient-card-1" elevation="2">
            <v-card-text class="pt-6">
              <div class="text-h2 font-weight-bold text-white mb-2">
                {{ dashboardData.total_projects }}
              </div>
              <div class="text-subtitle-1 font-weight-medium text-white">
                Total Projects
              </div>
              <div class="text-caption mt-2 text-white-70">
                All your projects
              </div>
            </v-card-text>
            <v-card-actions>
              <v-icon icon="mdi-folder-multiple" class="text-white" size="large"></v-icon>
            </v-card-actions>
          </v-card>
        </v-col>

        <v-col cols="12" sm="6" md="3">
          <v-card class="h-100 gradient-card-2" elevation="2">
            <v-card-text class="pt-6">
              <div class="text-h2 font-weight-bold text-white mb-2">
                {{ dashboardData.active_projects }}
              </div>
              <div class="text-subtitle-1 font-weight-medium text-white">
                Active Projects
              </div>
              <div class="text-caption mt-2 text-white-70">
                In Progress
              </div>
            </v-card-text>
            <v-card-actions>
              <v-icon icon="mdi-lightning-bolt" class="text-white" size="large"></v-icon>
            </v-card-actions>
          </v-card>
        </v-col>

        <v-col cols="12" sm="6" md="3">
          <v-card class="h-100 gradient-card-3" elevation="2">
            <v-card-text class="pt-6">
              <div class="text-h2 font-weight-bold text-white mb-2">
                {{ dashboardData.completed_projects }}
              </div>
              <div class="text-subtitle-1 font-weight-medium text-white">
                Completed
              </div>
              <div class="text-caption mt-2 text-white-70">
                Projects completed
              </div>
            </v-card-text>
            <v-card-actions>
              <v-icon icon="mdi-check-circle" class="text-white" size="large"></v-icon>
            </v-card-actions>
          </v-card>
        </v-col>

        <v-col cols="12" sm="6" md="3">
          <v-card class="h-100 gradient-card-4" elevation="2">
            <v-card-text class="pt-6">
              <div class="text-h2 font-weight-bold text-white mb-2">
                {{ dashboardData.overdue_tasks }}
              </div>
              <div class="text-subtitle-1 font-weight-medium text-white">
                Overdue Tasks
              </div>
              <div class="text-caption mt-2 text-white-70">
                Need attention
              </div>
            </v-card-text>
            <v-card-actions>
              <v-icon icon="mdi-alert-circle" class="text-white" size="large"></v-icon>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>

      <!-- Tasks Statistics -->
      <v-row class="mb-6">
        <v-col cols="12" sm="6" md="4">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-4">Total Tasks</v-card-title>
            <div class="d-flex align-center">
              <div class="flex-grow-1">
                <div class="text-h3 font-weight-bold text-primary">
                  {{ dashboardData.total_tasks }}
                </div>
                <v-progress-linear
                  :value="tasksCompletionPercentage"
                  color="primary"
                  height="8"
                  class="mt-4"
                ></v-progress-linear>
                <div class="text-caption text-grey mt-2">
                  {{ tasksCompletionPercentage }}% complete
                </div>
              </div>
            </div>
          </v-card>
        </v-col>

        <v-col cols="12" sm="6" md="4">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-4">Completed Tasks</v-card-title>
            <div class="d-flex align-center">
              <div class="flex-grow-1">
                <div class="text-h3 font-weight-bold text-success">
                  {{ dashboardData.completed_tasks }}
                </div>
                <v-progress-linear
                  value="100"
                  color="success"
                  height="8"
                  class="mt-4"
                ></v-progress-linear>
                <div class="text-caption text-grey mt-2">
                  All finished
                </div>
              </div>
            </div>
          </v-card>
        </v-col>

        <v-col cols="12" sm="6" md="4">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-4">This Week</v-card-title>
            <div class="d-flex align-center">
              <div class="flex-grow-1">
                <div class="text-h3 font-weight-bold text-info">
                  {{ dashboardData.time_logged_this_week }}
                </div>
                <v-progress-linear
                  :value="weekPercentage"
                  color="info"
                  height="8"
                  class="mt-4"
                ></v-progress-linear>
                <div class="text-caption text-grey mt-2">
                  Tasks this week
                </div>
              </div>
            </div>
          </v-card>
        </v-col>
      </v-row>

      <!-- Charts Section -->
      <v-row class="mb-6">
        <v-col cols="12" md="6">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-6">Projects by Status</v-card-title>
            <div class="space-y-4">
              <div v-for="(count, status) in dashboardData.projects_by_status" :key="status">
                <div class="d-flex justify-space-between align-center mb-2">
                  <span class="font-weight-medium">{{ status }}</span>
                  <span class="text-caption font-weight-bold">{{ count }}</span>
                </div>
                <v-progress-linear
                  :value="getPercentage(count, totalProjectsForChart)"
                  :color="getStatusChartColor(status)"
                  height="12"
                  rounded
                ></v-progress-linear>
              </div>
            </div>
          </v-card>
        </v-col>

        <v-col cols="12" md="6">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-6">Tasks by Priority</v-card-title>
            <div class="space-y-4">
              <div v-for="(count, priority) in dashboardData.tasks_by_priority" :key="priority">
                <div class="d-flex justify-space-between align-center mb-2">
                  <span class="font-weight-medium">{{ priority }} Priority</span>
                  <span class="text-caption font-weight-bold">{{ count }}</span>
                </div>
                <v-progress-linear
                  :value="getPercentage(count, totalTasksForChart)"
                  :color="getPriorityChartColor(priority)"
                  height="12"
                  rounded
                ></v-progress-linear>
              </div>
            </div>
          </v-card>
        </v-col>
      </v-row>

      <!-- Recent Activity Timeline -->
      <v-row>
        <v-col cols="12">
          <v-card elevation="1" class="pa-6">
            <v-card-title class="pa-0 mb-6">Recent Activity</v-card-title>
            <ActivityTimeline :activities="dashboardData.recent_activities" />
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <style scoped>
      .gradient-card-1 {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      }

      .gradient-card-2 {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
      }

      .gradient-card-3 {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
      }

      .gradient-card-4 {
        background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
      }

      .text-white-70 {
        color: rgba(255, 255, 255, 0.7);
      }

      .space-y-4 > div + div {
        margin-top: 1.5rem;
      }
    </style>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import ActivityTimeline from './ActivityTimeline.vue'
import { useWebSocket } from '../composables/useWebSocket'

const dashboardData = ref({
  total_projects: 0,
  active_projects: 0,
  completed_projects: 0,
  total_tasks: 0,
  completed_tasks: 0,
  overdue_tasks: 0,
  recent_activities: [],
  projects_by_status: {},
  tasks_by_priority: {},
  time_logged_this_week: 0
})

const loading = ref(false)
const ws = useWebSocket()
const connectionInfo = ref({
  status: 'disconnected',
  message: 'Not connected'
})

// Track activity updates from WebSocket
const activityUpdatesReceived = ref(0)

const tasksCompletionPercentage = computed(() => {
  if (dashboardData.value.total_tasks === 0) return 0
  return Math.round(
    (dashboardData.value.completed_tasks / dashboardData.value.total_tasks) * 100
  )
})

const weekPercentage = computed(() => {
  return Math.min(dashboardData.value.time_logged_this_week * 10, 100)
})

const totalProjectsForChart = computed(() => {
  return Object.values(dashboardData.value.projects_by_status).reduce((a, b) => a + b, 0)
})

const totalTasksForChart = computed(() => {
  return Object.values(dashboardData.value.tasks_by_priority).reduce((a, b) => a + b, 0)
})

const fetchDashboardData = async () => {
  loading.value = true
  try {
    const response = await axios.get('/dashboard.json')
    dashboardData.value = response.data.dashboard_data
  } catch (error) {
    console.error('Error fetching dashboard data:', error)
  } finally {
    loading.value = false
  }
}

const initializeWebSocket = () => {
  // Connect to WebSocket
  ws.connect()

  // Monitor connection status
  const statusCheckInterval = setInterval(() => {
    connectionInfo.value.status = ws.connectionStatus.value
    connectionInfo.value.message = ws.isHealthy()
      ? 'Real-time connection active'
      : 'Connection recovering'
  }, 1000)

  // Subscribe to activity updates for all projects
  // This would require fetching the user's projects first
  const subscribeToProjectActivities = () => {
    const projects = dashboardData.value.recent_activities
      .map((a) => a.project_id)
      .filter((id, i, arr) => arr.indexOf(id) === i) // Get unique project IDs

    projects.forEach((projectId) => {
      if (projectId) {
        ws.subscribe('ActivityChannel', { project_id: projectId })

        // Handle activity messages
        ws.onMessage('ActivityChannel', (data) => {
          if (data.type === 'activity_created' && data.activity) {
            // Add new activity to the top of the list
            dashboardData.value.recent_activities.unshift(data.activity)
            // Keep only last 50 activities
            if (dashboardData.value.recent_activities.length > 50) {
              dashboardData.value.recent_activities.pop()
            }
            activityUpdatesReceived.value++
          }
        })
      }
    })
  }

  // Subscribe after initial data is loaded
  const dataCheckInterval = setInterval(() => {
    if (dashboardData.value.recent_activities.length > 0) {
      subscribeToProjectActivities()
      clearInterval(dataCheckInterval)
    }
  }, 500)

  // Cleanup
  onUnmounted(() => {
    clearInterval(statusCheckInterval)
    clearInterval(dataCheckInterval)
    ws.disconnect()
  })
}

const getPercentage = (value, total) => {
  if (total === 0) return 0
  return Math.round((value / total) * 100)
}

const getStatusChartColor = (status) => {
  const colors = {
    'Not Started': 'grey',
    'In Progress': 'blue',
    'Completed': 'green',
    'On Hold': 'orange'
  }
  return colors[status] || 'grey'
}

const getPriorityChartColor = (priority) => {
  const colors = {
    'Low': 'green',
    'Medium': 'orange',
    'High': 'red'
  }
  return colors[priority] || 'grey'
}

const navigateToNewProject = () => {
  window.location.href = '/projects/new'
}

const navigateToNewTask = () => {
  // Navigate to new task page - adjust the path as needed for your app structure
  alert('Navigate to create new task - customize this route based on your app structure')
}

onMounted(() => {
  fetchDashboardData()
  initializeWebSocket()
})
</script>
