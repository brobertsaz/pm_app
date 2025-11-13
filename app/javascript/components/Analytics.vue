<template>
  <v-app>
    <v-container>
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="text-h5">Analytics Dashboard</v-card-title>
            <v-card-subtitle>Project and team performance insights</v-card-subtitle>

            <v-card-text>
              <v-row class="mb-6">
                <v-col cols="12" sm="6" md="3">
                  <v-stat-card title="Total Projects" :value="stats.projectCount" icon="mdi-briefcase"></v-stat-card>
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-stat-card title="Total Tasks" :value="stats.taskCount" icon="mdi-checkbox-marked-circle"></v-stat-card>
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-stat-card title="Completed Projects" :value="stats.completedProjects" icon="mdi-check-circle"></v-stat-card>
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-stat-card title="Completed Tasks" :value="stats.completedTasks" icon="mdi-check"></v-stat-card>
                </v-col>
              </v-row>

              <v-divider class="my-6"></v-divider>

              <!-- Date Range Selector -->
              <v-row class="mb-6">
                <v-col cols="12" sm="6">
                  <v-text-field
                    v-model="startDate"
                    label="Start Date"
                    type="date"
                    @change="refreshTimeReports"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" sm="6">
                  <v-text-field
                    v-model="endDate"
                    label="End Date"
                    type="date"
                    @change="refreshTimeReports"
                  ></v-text-field>
                </v-col>
              </v-row>

              <!-- Tabs for different analytics views -->
              <v-tabs v-model="activeTab">
                <v-tab value="projects">Project Performance</v-tab>
                <v-tab value="time">Time Tracking</v-tab>
                <v-tab value="team">Team Productivity</v-tab>
                <v-tab value="burndown">Burndown</v-tab>
              </v-tabs>

              <v-window v-model="activeTab">
                <!-- Project Performance Tab -->
                <v-window-item value="projects">
                  <v-card flat>
                    <v-card-text>
                      <div v-if="projectPerformance.length > 0">
                        <v-row>
                          <v-col cols="12" md="6">
                            <canvas ref="projectCompletionChart"></canvas>
                          </v-col>
                          <v-col cols="12" md="6">
                            <canvas ref="taskStatusChart"></canvas>
                          </v-col>
                        </v-row>

                        <v-divider class="my-6"></v-divider>

                        <v-data-table
                          :headers="projectHeaders"
                          :items="projectPerformance"
                          class="elevation-1"
                        >
                          <template v-slot:item.completion_percentage="{ item }">
                            <v-progress-linear
                              :value="item.completion_percentage"
                              :color="getProgressColor(item.completion_percentage)"
                              class="ma-2"
                            ></v-progress-linear>
                          </template>
                          <template v-slot:item.status="{ item }">
                            <v-chip :color="getStatusColor(item.status)" size="small">
                              {{ item.status }}
                            </v-chip>
                          </template>
                        </v-data-table>
                      </div>
                      <v-alert v-else type="info">No project data available</v-alert>
                    </v-card-text>
                  </v-card>
                </v-window-item>

                <!-- Time Tracking Tab -->
                <v-window-item value="time">
                  <v-card flat>
                    <v-card-text>
                      <v-row>
                        <v-col cols="12" md="6">
                          <h3 class="text-subtitle1 mb-4">Time by Project</h3>
                          <canvas ref="timeByProjectChart"></canvas>
                        </v-col>
                        <v-col cols="12" md="6">
                          <h3 class="text-subtitle1 mb-4">Time by User</h3>
                          <canvas ref="timeByUserChart"></canvas>
                        </v-col>
                      </v-row>

                      <v-divider class="my-6"></v-divider>

                      <v-row>
                        <v-col cols="12">
                          <div class="text-h6 mb-4">Total Time Logged: {{ timeData.total_hours }} hours</div>
                          <v-data-table
                            :headers="timeHeaders"
                            :items="timeData.projects_time"
                            class="elevation-1 mb-6"
                          >
                            <template v-slot:top>
                              <v-toolbar flat>
                                <v-toolbar-title>Time by Project</v-toolbar-title>
                              </v-toolbar>
                            </template>
                          </v-data-table>

                          <v-data-table
                            :headers="userTimeHeaders"
                            :items="timeData.users_time"
                            class="elevation-1"
                          >
                            <template v-slot:top>
                              <v-toolbar flat>
                                <v-toolbar-title>Time by User</v-toolbar-title>
                              </v-toolbar>
                            </template>
                          </v-data-table>
                        </v-col>
                      </v-row>

                      <v-btn
                        color="primary"
                        @click="exportTimeData"
                        prepend-icon="mdi-download"
                        class="mt-4"
                      >
                        Export Time Data
                      </v-btn>
                    </v-card-text>
                  </v-card>
                </v-window-item>

                <!-- Team Productivity Tab -->
                <v-window-item value="team">
                  <v-card flat>
                    <v-card-text>
                      <div v-if="teamProductivity.length > 0">
                        <v-row v-for="project in teamProductivity" :key="project.project_id" class="mb-6">
                          <v-col cols="12">
                            <v-card>
                              <v-card-title>{{ project.project_name }}</v-card-title>
                              <v-card-text>
                                <v-data-table
                                  :headers="teamHeaders"
                                  :items="project.team_members"
                                  class="elevation-1"
                                >
                                  <template v-slot:item.completion_rate="{ item }">
                                    <v-progress-linear
                                      :value="item.completion_rate"
                                      :color="getProgressColor(item.completion_rate)"
                                      class="ma-2"
                                    ></v-progress-linear>
                                  </template>
                                </v-data-table>
                              </v-card-text>
                            </v-card>
                          </v-col>
                        </v-row>

                        <v-btn
                          color="primary"
                          @click="exportTeamData"
                          prepend-icon="mdi-download"
                          class="mt-4"
                        >
                          Export Team Data
                        </v-btn>
                      </div>
                      <v-alert v-else type="info">No team data available</v-alert>
                    </v-card-text>
                  </v-card>
                </v-window-item>

                <!-- Burndown Tab -->
                <v-window-item value="burndown">
                  <v-card flat>
                    <v-card-text>
                      <v-select
                        v-model="selectedProject"
                        :items="projectPerformance"
                        item-title="name"
                        item-value="id"
                        label="Select Project"
                        class="mb-4"
                        @update:model-value="loadBurndownChart"
                      ></v-select>

                      <div v-if="burndownData">
                        <canvas ref="burndownChart"></canvas>
                        <v-divider class="my-4"></v-divider>
                        <v-alert type="info" class="mt-4">
                          <strong>{{ burndownData.project_name }}</strong><br>
                          Period: {{ burndownData.start_date }} to {{ burndownData.end_date }}<br>
                          Total Tasks: {{ burndownData.total_tasks }}
                        </v-alert>
                      </div>
                      <v-alert v-else type="warning">Select a project to view burndown chart</v-alert>
                    </v-card-text>
                  </v-card>
                </v-window-item>
              </v-window>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { Chart as ChartJS, ArcElement, BarElement, CategoryScale, Legend, LineElement, LinearScale, Title, Tooltip } from 'chart.js'
import { Bar, Doughnut, Line } from 'vue-chartjs'

ChartJS.register(
  ArcElement,
  BarElement,
  CategoryScale,
  Legend,
  LineElement,
  LinearScale,
  Title,
  Tooltip
)

// Components
const StatCard = { template: '<div class="stat-card"><v-card><v-card-text><v-row><v-col cols="3"><v-icon size="48">{{ icon }}</v-icon></v-col><v-col cols="9"><div class="text-h6">{{ value }}</div><div class="text-caption text-disabled">{{ title }}</div></v-col></v-row></v-card-text></v-card></div>' }

// Refs
const projectCompletionChart = ref(null)
const taskStatusChart = ref(null)
const timeByProjectChart = ref(null)
const timeByUserChart = ref(null)
const burndownChart = ref(null)

const stats = ref({
  projectCount: 0,
  taskCount: 0,
  completedProjects: 0,
  completedTasks: 0
})

const projectPerformance = ref([])
const timeData = ref({
  projects_time: [],
  users_time: [],
  total_hours: 0
})
const teamProductivity = ref([])
const burndownData = ref(null)

const activeTab = ref('projects')
const startDate = ref(new Date(new Date().setMonth(new Date().getMonth() - 1)).toISOString().split('T')[0])
const endDate = ref(new Date().toISOString().split('T')[0])
const selectedProject = ref(null)

const projectHeaders = [
  { title: 'Project', key: 'name', sortable: true },
  { title: 'Status', key: 'status', sortable: true },
  { title: 'Completion', key: 'completion_percentage', sortable: true },
  { title: 'Completed', key: 'completed_tasks', sortable: true },
  { title: 'Total Tasks', key: 'total_tasks', sortable: true }
]

const timeHeaders = [
  { title: 'Project', key: 'project_name', sortable: true },
  { title: 'Total Hours', key: 'total_hours', sortable: true },
  { title: 'Entries', key: 'entry_count', sortable: true },
  { title: 'Avg Hours', key: 'average_hours', sortable: true }
]

const userTimeHeaders = [
  { title: 'User', key: 'user_email', sortable: true },
  { title: 'Total Hours', key: 'total_hours', sortable: true },
  { title: 'Entries', key: 'entry_count', sortable: true },
  { title: 'Avg Hours', key: 'average_hours', sortable: true }
]

const teamHeaders = [
  { title: 'Member', key: 'user_email', sortable: true },
  { title: 'Completed', key: 'completed_tasks', sortable: true },
  { title: 'Total Tasks', key: 'total_tasks', sortable: true },
  { title: 'Completion Rate', key: 'completion_rate', sortable: true },
  { title: 'Time Logged', key: 'total_time_logged', sortable: true }
]

// Methods
const fetchStats = async () => {
  try {
    const response = await axios.get('/analytics')
    // Parse stats from HTML response (this is a fallback)
    stats.value = {
      projectCount: response.data?.project_count || 0,
      taskCount: response.data?.task_count || 0,
      completedProjects: response.data?.completed_projects || 0,
      completedTasks: response.data?.completed_tasks || 0
    }
  } catch (error) {
    console.error('Error fetching stats:', error)
  }
}

const fetchProjectPerformance = async () => {
  try {
    const response = await axios.get('/analytics/project_performance')
    projectPerformance.value = response.data.projects
    if (projectPerformance.value.length > 0) {
      selectedProject.value = projectPerformance.value[0].id
      renderProjectCharts()
    }
  } catch (error) {
    console.error('Error fetching project performance:', error)
  }
}

const fetchTimeReports = async () => {
  try {
    const response = await axios.get('/analytics/time_reports', {
      params: {
        start_date: startDate.value,
        end_date: endDate.value
      }
    })
    timeData.value = response.data
    renderTimeCharts()
  } catch (error) {
    console.error('Error fetching time reports:', error)
  }
}

const fetchTeamProductivity = async () => {
  try {
    const response = await axios.get('/analytics/team_productivity')
    teamProductivity.value = response.data.team_productivity
  } catch (error) {
    console.error('Error fetching team productivity:', error)
  }
}

const loadBurndownChart = async () => {
  if (!selectedProject.value) return

  try {
    const response = await axios.get(`/analytics/burndown_chart`, {
      params: {
        project_id: selectedProject.value,
        start_date: startDate.value,
        end_date: endDate.value
      }
    })
    burndownData.value = response.data
    renderBurndownChart()
  } catch (error) {
    console.error('Error fetching burndown chart:', error)
  }
}

const renderProjectCharts = () => {
  const ctx = projectCompletionChart.value
  if (!ctx) return

  const labels = projectPerformance.value.map(p => p.name)
  const completion = projectPerformance.value.map(p => p.completion_percentage)

  new ChartJS(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label: 'Completion %',
        data: completion,
        backgroundColor: 'rgba(75, 192, 192, 0.8)'
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          max: 100
        }
      }
    }
  })

  const statusCtx = taskStatusChart.value
  if (statusCtx) {
    const statusData = {
      todo: 0,
      inProgress: 0,
      done: 0
    }

    projectPerformance.value.forEach(p => {
      statusData.todo += p.to_do_tasks
      statusData.inProgress += p.in_progress_tasks
      statusData.done += p.completed_tasks
    })

    new ChartJS(statusCtx, {
      type: 'doughnut',
      data: {
        labels: ['To Do', 'In Progress', 'Done'],
        datasets: [{
          data: [statusData.todo, statusData.inProgress, statusData.done],
          backgroundColor: ['#9E9E9E', '#2196F3', '#4CAF50']
        }]
      },
      options: { responsive: true }
    })
  }
}

const renderTimeCharts = () => {
  const projectCtx = timeByProjectChart.value
  if (projectCtx && timeData.value.projects_time.length > 0) {
    const labels = timeData.value.projects_time.map(p => p.project_name)
    const data = timeData.value.projects_time.map(p => p.total_hours)

    new ChartJS(projectCtx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: 'Hours',
          data,
          backgroundColor: 'rgba(153, 102, 255, 0.8)'
        }]
      },
      options: { responsive: true }
    })
  }

  const userCtx = timeByUserChart.value
  if (userCtx && timeData.value.users_time.length > 0) {
    const labels = timeData.value.users_time.map(u => u.user_email)
    const data = timeData.value.users_time.map(u => u.total_hours)

    new ChartJS(userCtx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: 'Hours',
          data,
          backgroundColor: 'rgba(255, 159, 64, 0.8)'
        }]
      },
      options: { responsive: true }
    })
  }
}

const renderBurndownChart = () => {
  const ctx = burndownChart.value
  if (!ctx || !burndownData.value) return

  const dates = Object.keys(burndownData.value.actual_remaining)
  const actualData = dates.map(d => burndownData.value.actual_remaining[d])
  const idealData = dates.map(d => burndownData.value.ideal_remaining[d])

  new ChartJS(ctx, {
    type: 'line',
    data: {
      labels: dates,
      datasets: [
        {
          label: 'Actual',
          data: actualData,
          borderColor: '#F44336',
          backgroundColor: 'rgba(244, 67, 54, 0.1)',
          tension: 0.1
        },
        {
          label: 'Ideal',
          data: idealData,
          borderColor: '#4CAF50',
          backgroundColor: 'rgba(76, 175, 80, 0.1)',
          tension: 0.1,
          borderDash: [5, 5]
        }
      ]
    },
    options: { responsive: true }
  })
}

const refreshTimeReports = async () => {
  await fetchTimeReports()
}

const exportTimeData = () => {
  const csv = generateCSV(timeData.value.projects_time, ['project_name', 'total_hours', 'entry_count', 'average_hours'])
  downloadCSV(csv, 'time-tracking.csv')
}

const exportTeamData = () => {
  const allMembers = []
  teamProductivity.value.forEach(project => {
    project.team_members.forEach(member => {
      allMembers.push({
        project_name: project.project_name,
        user_email: member.user_email,
        completed_tasks: member.completed_tasks,
        total_tasks: member.total_tasks,
        completion_rate: member.completion_rate,
        total_time_logged: member.total_time_logged
      })
    })
  })
  const csv = generateCSV(allMembers, ['project_name', 'user_email', 'completed_tasks', 'total_tasks', 'completion_rate', 'total_time_logged'])
  downloadCSV(csv, 'team-productivity.csv')
}

const generateCSV = (data, headers) => {
  const csvContent = [
    headers.join(','),
    ...data.map(row => headers.map(h => row[h]).join(','))
  ].join('\n')
  return csvContent
}

const downloadCSV = (csv, filename) => {
  const link = document.createElement('a')
  link.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv)
  link.download = filename
  link.click()
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

const getProgressColor = (value) => {
  if (value >= 75) return 'success'
  if (value >= 50) return 'warning'
  if (value >= 25) return 'info'
  return 'error'
}

onMounted(() => {
  fetchStats()
  fetchProjectPerformance()
  fetchTimeReports()
  fetchTeamProductivity()
})
</script>

<style scoped>
.stat-card {
  margin-bottom: 20px;
}
</style>
