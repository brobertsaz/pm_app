<template>
  <v-app>
    <v-container fluid class="py-6">
      <!-- Header -->
      <v-row>
        <v-col cols="12">
          <div class="d-flex justify-space-between align-center mb-6">
            <h1 class="text-h4 font-weight-bold">Calendar</h1>
            <div class="d-flex gap-3">
              <v-select
                v-model="selectedProjectId"
                :items="projectOptions"
                label="Filter by Project"
                outlined
                dense
                clearable
                style="max-width: 250px"
              ></v-select>
            </div>
          </div>
        </v-col>
      </v-row>

      <!-- Calendar Navigation -->
      <v-row class="mb-6">
        <v-col cols="12">
          <v-card elevation="2" class="pa-4">
            <div class="d-flex justify-space-between align-center mb-4">
              <v-btn icon @click="previousMonth">
                <v-icon>mdi-chevron-left</v-icon>
              </v-btn>
              <h2 class="text-h6">{{ currentMonthYear }}</h2>
              <v-btn icon @click="nextMonth">
                <v-icon>mdi-chevron-right</v-icon>
              </v-btn>
              <v-spacer></v-spacer>
              <v-btn variant="outlined" @click="goToToday">Today</v-btn>
            </div>

            <!-- Weekday Headers -->
            <v-row class="mb-2">
              <v-col v-for="day in weekDays" :key="day" cols="12" sm="6" md="4" lg="2" xl="1" class="mb-2">
                <div class="text-center font-weight-bold text-subtitle-2">{{ day }}</div>
              </v-col>
            </v-row>

            <!-- Calendar Grid -->
            <v-row class="calendar-grid">
              <v-col
                v-for="day in calendarDays"
                :key="day.date"
                cols="12"
                sm="6"
                md="4"
                lg="2"
                xl="1"
                class="mb-2"
              >
                <v-card
                  :class="[
                    'calendar-day-card',
                    { 'other-month': day.isOtherMonth },
                    { 'today': day.isToday },
                    { 'has-events': day.events.length > 0 }
                  ]"
                  elevation="1"
                  @click="selectDay(day)"
                >
                  <div class="day-header" :class="{ 'today-header': day.isToday }">
                    <span class="day-number">{{ day.dayOfMonth }}</span>
                  </div>

                  <div class="day-events">
                    <div
                      v-for="event in day.events.slice(0, 3)"
                      :key="event.id"
                      class="event-item"
                      :class="`event-${event.extendedProps.priority || 'low'}`"
                      :style="{ backgroundColor: event.backgroundColor }"
                      @click.stop="openEventDetails(event)"
                    >
                      <v-icon size="xs">{{ getEventIcon(event) }}</v-icon>
                      <span class="event-title">{{ event.title }}</span>
                    </div>
                    <div v-if="day.events.length > 3" class="more-events">
                      +{{ day.events.length - 3 }} more
                    </div>
                  </div>
                </v-card>
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>

      <!-- Selected Day Events -->
      <v-row v-if="selectedDate" class="mb-6">
        <v-col cols="12">
          <v-card elevation="2" class="pa-6">
            <h2 class="text-h6 mb-4">
              Events for {{ formatDate(selectedDate.date) }}
            </h2>
            <div v-if="selectedDate.events.length > 0" class="events-list">
              <v-card
                v-for="event in selectedDate.events"
                :key="event.id"
                class="mb-3 event-card"
                :class="`event-type-${event.extendedProps.type}`"
              >
                <v-card-title class="d-flex align-center gap-2">
                  <v-icon :color="getPriorityColor(event.extendedProps.priority)">
                    {{ getEventIcon(event) }}
                  </v-icon>
                  {{ event.title }}
                </v-card-title>
                <v-card-subtitle>
                  {{ event.extendedProps.projectName }}
                </v-card-subtitle>
                <v-card-text>
                  <v-row>
                    <v-col cols="12" sm="6">
                      <strong>Status:</strong>
                      <v-chip
                        v-if="event.extendedProps.status"
                        :color="getStatusColor(event.extendedProps.status)"
                        label
                        size="small"
                        class="ml-2"
                      >
                        {{ event.extendedProps.status }}
                      </v-chip>
                    </v-col>
                    <v-col cols="12" sm="6">
                      <strong>Priority:</strong>
                      <v-chip
                        v-if="event.extendedProps.priority"
                        :color="getPriorityColor(event.extendedProps.priority)"
                        label
                        size="small"
                        class="ml-2"
                        text-color="white"
                      >
                        {{ event.extendedProps.priority }}
                      </v-chip>
                    </v-col>
                    <v-col v-if="event.extendedProps.assignee" cols="12" sm="6">
                      <strong>Assigned to:</strong>
                      <span class="ml-2">{{ event.extendedProps.assignee }}</span>
                    </v-col>
                  </v-row>
                  <v-row v-if="event.extendedProps.description" class="mt-2">
                    <v-col cols="12">
                      <strong>Description:</strong>
                      <p class="mt-2">{{ event.extendedProps.description }}</p>
                    </v-col>
                  </v-row>
                </v-card-text>
                <v-card-actions>
                  <v-btn
                    v-if="event.extendedProps.type === 'task'"
                    size="small"
                    color="primary"
                    @click="editTask(event)"
                  >
                    Edit Task
                  </v-btn>
                  <v-btn
                    v-else
                    size="small"
                    color="primary"
                    @click="editProject(event)"
                  >
                    Edit Project
                  </v-btn>
                </v-card-actions>
              </v-card>
            </div>
            <div v-else class="text-center text-grey">
              No events scheduled for this day
            </div>
          </v-card>
        </v-col>
      </v-row>

      <!-- Legend -->
      <v-row>
        <v-col cols="12">
          <v-card elevation="1" class="pa-4">
            <h3 class="text-h6 mb-4">Legend</h3>
            <v-row>
              <v-col cols="12" sm="6" md="3">
                <div class="d-flex align-center gap-2">
                  <div class="legend-box high-priority"></div>
                  <span>High Priority</span>
                </div>
              </v-col>
              <v-col cols="12" sm="6" md="3">
                <div class="d-flex align-center gap-2">
                  <div class="legend-box medium-priority"></div>
                  <span>Medium Priority</span>
                </div>
              </v-col>
              <v-col cols="12" sm="6" md="3">
                <div class="d-flex align-center gap-2">
                  <div class="legend-box low-priority"></div>
                  <span>Low Priority</span>
                </div>
              </v-col>
              <v-col cols="12" sm="6" md="3">
                <div class="d-flex align-center gap-2">
                  <v-icon size="sm" class="mr-2">mdi-folder</v-icon>
                  <span>Project Deadline</span>
                </div>
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>
    </v-container>

    <style scoped>
      .calendar-grid {
        gap: 8px;
      }

      .calendar-day-card {
        cursor: pointer;
        transition: all 0.3s ease;
        min-height: 120px;
        position: relative;
        overflow: hidden;
      }

      .calendar-day-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      }

      .calendar-day-card.other-month {
        background-color: #f5f5f5;
        opacity: 0.5;
      }

      .calendar-day-card.today {
        border: 2px solid #1976d2;
        background-color: #e3f2fd;
      }

      .calendar-day-card.has-events {
        border-left: 4px solid #1976d2;
      }

      .day-header {
        padding: 8px 4px;
        background-color: #f5f5f5;
        border-bottom: 1px solid #eee;
      }

      .day-header.today-header {
        background-color: #1976d2;
      }

      .day-number {
        font-weight: 600;
        font-size: 14px;
      }

      .day-header.today-header .day-number {
        color: white;
      }

      .day-events {
        padding: 4px 2px;
        max-height: 100px;
        overflow: hidden;
      }

      .event-item {
        padding: 2px 4px;
        margin: 2px 0;
        border-radius: 3px;
        font-size: 11px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        color: white;
        display: flex;
        align-items: center;
        gap: 4px;
        cursor: pointer;
      }

      .event-item:hover {
        opacity: 0.8;
      }

      .event-title {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        font-weight: 500;
      }

      .more-events {
        padding: 2px 4px;
        font-size: 10px;
        color: #666;
        font-weight: 500;
      }

      .events-list {
        max-height: 600px;
        overflow-y: auto;
      }

      .event-card {
        border-left: 4px solid #1976d2;
      }

      .event-card.event-type-project {
        border-left-color: #f57c00;
      }

      .legend-box {
        width: 16px;
        height: 16px;
        border-radius: 3px;
      }

      .legend-box.high-priority {
        background-color: #ef5350;
      }

      .legend-box.medium-priority {
        background-color: #ffa726;
      }

      .legend-box.low-priority {
        background-color: #66bb6a;
      }
    </style>
  </v-app>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'

const currentDate = ref(new Date())
const selectedDate = ref(null)
const selectedProjectId = ref(null)
const projects = ref([])
const events = ref([])
const loading = ref(false)

const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

const currentMonthYear = computed(() => {
  return currentDate.value.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
})

const projectOptions = computed(() => {
  return projects.value.map(p => ({ title: p.name, value: p.id }))
})

const calendarDays = computed(() => {
  const year = currentDate.value.getFullYear()
  const month = currentDate.value.getMonth()

  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)
  const daysInMonth = lastDay.getDate()
  const startingDayOfWeek = firstDay.getDay()

  const days = []

  // Previous month's days
  const previousMonth = new Date(year, month, 0)
  const daysInPreviousMonth = previousMonth.getDate()
  for (let i = daysInPreviousMonth - startingDayOfWeek + 1; i <= daysInPreviousMonth; i++) {
    days.push({
      date: new Date(year, month - 1, i),
      dayOfMonth: i,
      isOtherMonth: true,
      events: []
    })
  }

  // Current month's days
  for (let i = 1; i <= daysInMonth; i++) {
    days.push({
      date: new Date(year, month, i),
      dayOfMonth: i,
      isOtherMonth: false,
      isToday: isToday(new Date(year, month, i)),
      events: []
    })
  }

  // Next month's days
  const remainingDays = 42 - days.length
  for (let i = 1; i <= remainingDays; i++) {
    days.push({
      date: new Date(year, month + 1, i),
      dayOfMonth: i,
      isOtherMonth: true,
      events: []
    })
  }

  // Add events to days
  events.value.forEach(event => {
    const eventDate = new Date(event.start)
    const dayIndex = days.findIndex(
      d => d.date.toDateString() === eventDate.toDateString()
    )
    if (dayIndex !== -1) {
      days[dayIndex].events.push(event)
    }
  })

  return days
})

const isToday = (date) => {
  const today = new Date()
  return (
    date.getDate() === today.getDate() &&
    date.getMonth() === today.getMonth() &&
    date.getFullYear() === today.getFullYear()
  )
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const previousMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() - 1)
  fetchEvents()
}

const nextMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + 1)
  fetchEvents()
}

const goToToday = () => {
  currentDate.value = new Date()
  fetchEvents()
}

const selectDay = (day) => {
  selectedDate.value = day
}

const openEventDetails = (event) => {
  console.log('Event details:', event)
}

const editTask = (event) => {
  const projectId = event.extendedProps.projectId
  const taskId = event.id.split('-')[1]
  window.location.href = `/projects/${projectId}/tasks/${taskId}`
}

const editProject = (event) => {
  const projectId = event.id.split('-')[1]
  window.location.href = `/projects/${projectId}`
}

const getEventIcon = (event) => {
  return event.extendedProps.type === 'project' ? 'mdi-folder-outline' : 'mdi-checkbox-marked-circle-outline'
}

const getPriorityColor = (priority) => {
  const colors = {
    'High': 'red',
    'Medium': 'orange',
    'Low': 'green'
  }
  return colors[priority] || 'blue'
}

const getStatusColor = (status) => {
  const colors = {
    'Done': 'success',
    'In Progress': 'info',
    'To Do': 'warning',
    'Not Started': 'grey',
    'Completed': 'success',
    'On Hold': 'orange'
  }
  return colors[status] || 'grey'
}

const fetchProjects = async () => {
  try {
    const response = await axios.get('/api/v1/projects')
    projects.value = Array.isArray(response.data) ? response.data : (response.data.data || [])
  } catch (error) {
    console.error('Error fetching projects:', error)
  }
}

const fetchEvents = async () => {
  loading.value = true
  try {
    const params = {
      start: new Date(currentDate.value.getFullYear(), currentDate.value.getMonth(), 1).toISOString().split('T')[0],
      end: new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + 1, 0).toISOString().split('T')[0]
    }

    if (selectedProjectId.value) {
      params.project_id = selectedProjectId.value
    }

    const response = await axios.get('/api/v1/calendar/events', { params })
    events.value = response.data.events || []
  } catch (error) {
    console.error('Error fetching events:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchProjects()
  fetchEvents()
})

// Watch for project filter changes
watch(() => selectedProjectId.value, () => {
  fetchEvents()
})
</script>
