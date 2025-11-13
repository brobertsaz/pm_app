<template>
  <v-card class="advanced-search-container">
    <v-container fluid>
      <v-row align="center" class="mb-4">
        <v-col cols="12" md="8">
          <v-text-field
            v-model="searchQuery"
            placeholder="Search projects and tasks..."
            prepend-inner-icon="mdi-magnify"
            variant="outlined"
            density="compact"
            clearable
            @input="debouncedSearch"
            @keyup.enter="performSearch"
          />
        </v-col>
        <v-col cols="12" md="4" class="text-right">
          <v-btn
            @click="showAdvancedFilters = !showAdvancedFilters"
            variant="outlined"
            size="small"
            :prepend-icon="showAdvancedFilters ? 'mdi-filter-off' : 'mdi-filter-outline'"
          >
            {{ showAdvancedFilters ? 'Hide Filters' : 'Show Filters' }}
          </v-btn>
        </v-col>
      </v-row>

      <!-- Advanced Filters Section -->
      <v-expand-transition>
        <div v-show="showAdvancedFilters" class="mb-6">
          <v-divider class="mb-4" />

          <v-row>
            <!-- Status Filter -->
            <v-col cols="12" sm="6" md="3">
              <v-select
                v-model="filters.status"
                :items="statusOptions"
                label="Status"
                variant="outlined"
                density="compact"
                clearable
                multiple
              />
            </v-col>

            <!-- Priority Filter -->
            <v-col cols="12" sm="6" md="3">
              <v-select
                v-model="filters.priority"
                :items="priorityOptions"
                label="Priority"
                variant="outlined"
                density="compact"
                clearable
                multiple
              />
            </v-col>

            <!-- Assigned User Filter -->
            <v-col cols="12" sm="6" md="3">
              <v-autocomplete
                v-model="filters.assignedUser"
                :items="users"
                item-title="full_name"
                item-value="id"
                label="Assigned To"
                variant="outlined"
                density="compact"
                clearable
              />
            </v-col>

            <!-- Tags Filter -->
            <v-col cols="12" sm="6" md="3">
              <v-autocomplete
                v-model="filters.tags"
                :items="tags"
                item-title="name"
                item-value="id"
                label="Tags"
                variant="outlined"
                density="compact"
                clearable
                multiple
              />
            </v-col>
          </v-row>

          <!-- Date Range Filter -->
          <v-row class="mt-2">
            <v-col cols="12" sm="6">
              <v-text-field
                v-model="filters.startDate"
                label="Start Date"
                type="date"
                variant="outlined"
                density="compact"
              />
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field
                v-model="filters.endDate"
                label="End Date"
                type="date"
                variant="outlined"
                density="compact"
              />
            </v-col>
          </v-row>

          <!-- Search Type -->
          <v-row class="mt-2">
            <v-col cols="12">
              <v-btn-toggle
                v-model="filters.searchType"
                variant="outlined"
                divided
              >
                <v-btn value="all" text="All">All</v-btn>
                <v-btn value="projects" text="Projects">Projects</v-btn>
                <v-btn value="tasks" text="Tasks">Tasks</v-btn>
              </v-btn-toggle>
            </v-col>
          </v-row>

          <!-- Filter Actions -->
          <v-row class="mt-4">
            <v-col>
              <v-btn
                @click="performSearch"
                variant="flat"
                color="primary"
                prepend-icon="mdi-magnify"
              >
                Search
              </v-btn>
              <v-btn
                @click="clearFilters"
                variant="text"
                class="ml-2"
              >
                Clear Filters
              </v-btn>
            </v-col>
          </v-row>
        </div>
      </v-expand-transition>

      <!-- Recent Searches -->
      <v-row v-if="recentSearches.length > 0 && !loading" class="mb-4">
        <v-col cols="12">
          <div class="text-subtitle-2 mb-2">Recent Searches:</div>
          <div class="d-flex flex-wrap gap-2">
            <v-chip
              v-for="search in recentSearches"
              :key="search"
              @click="searchQuery = search; performSearch()"
              closable
              @click:close="removeRecentSearch(search)"
              variant="outlined"
              size="small"
            >
              {{ search }}
            </v-chip>
          </div>
        </v-col>
      </v-row>

      <!-- Quick Filters -->
      <v-row v-if="!loading && results.length === 0 && searchQuery === ''" class="mb-4">
        <v-col cols="12">
          <div class="text-subtitle-2 mb-2">Quick Filters:</div>
          <v-btn-group class="d-flex flex-wrap">
            <v-btn
              @click="quickFilterMyTasks"
              size="small"
              variant="outlined"
              prepend-icon="mdi-check-circle"
            >
              My Tasks
            </v-btn>
            <v-btn
              @click="quickFilterHighPriority"
              size="small"
              variant="outlined"
              prepend-icon="mdi-alert-circle"
            >
              High Priority
            </v-btn>
            <v-btn
              @click="quickFilterOverdue"
              size="small"
              variant="outlined"
              prepend-icon="mdi-calendar-alert"
            >
              Overdue
            </v-btn>
            <v-btn
              @click="quickFilterInProgress"
              size="small"
              variant="outlined"
              prepend-icon="mdi-progress-check"
            >
              In Progress
            </v-btn>
          </v-btn-group>
        </v-col>
      </v-row>

      <!-- Loading State -->
      <v-row v-if="loading">
        <v-col cols="12" class="text-center">
          <v-progress-circular
            indeterminate
            color="primary"
          />
        </v-col>
      </v-row>

      <!-- Search Results -->
      <v-row v-if="!loading && results.length > 0">
        <v-col cols="12">
          <div class="text-subtitle-2 mb-3">
            {{ results.length }} results found
          </div>

          <!-- Projects Results -->
          <div v-if="projectResults.length > 0" class="mb-6">
            <v-divider class="mb-3">
              <v-chip label size="small">Projects ({{ projectResults.length }})</v-chip>
            </v-divider>

            <v-card
              v-for="project in projectResults"
              :key="`project-${project.id}`"
              class="mb-3 search-result-card"
            >
              <v-card-title>
                <v-row align="center">
                  <v-col>
                    <router-link :to="`/projects/${project.id}`" class="text-decoration-none">
                      {{ highlightText(project.name) }}
                    </router-link>
                  </v-col>
                  <v-col auto>
                    <v-chip
                      :text="project.status"
                      :color="getStatusColor(project.status)"
                      size="small"
                    />
                  </v-col>
                </v-row>
              </v-card-title>
              <v-card-text>
                <p>{{ highlightText(project.description) }}</p>
                <v-row>
                  <v-col>
                    <small class="text-muted">
                      Created: {{ formatDate(project.created_at) }}
                    </small>
                  </v-col>
                  <v-col>
                    <small class="text-muted">
                      Priority: {{ project.priority }}
                    </small>
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </div>

          <!-- Tasks Results -->
          <div v-if="taskResults.length > 0">
            <v-divider class="mb-3">
              <v-chip label size="small">Tasks ({{ taskResults.length }})</v-chip>
            </v-divider>

            <v-card
              v-for="task in taskResults"
              :key="`task-${task.id}`"
              class="mb-3 search-result-card"
            >
              <v-card-title>
                <v-row align="center">
                  <v-col>
                    <router-link :to="`/projects/${task.project_id}/tasks/${task.id}`" class="text-decoration-none">
                      {{ highlightText(task.title) }}
                    </router-link>
                    <div class="text-caption text-muted">
                      in {{ task.project_name }}
                    </div>
                  </v-col>
                  <v-col auto>
                    <v-chip
                      :text="task.status"
                      :color="getStatusColor(task.status)"
                      size="small"
                      class="mr-2"
                    />
                    <v-chip
                      :text="task.priority"
                      :color="getPriorityColor(task.priority)"
                      size="small"
                    />
                  </v-col>
                </v-row>
              </v-card-title>
              <v-card-text>
                <p v-if="task.description">{{ highlightText(task.description) }}</p>
                <v-row class="mt-2">
                  <v-col v-if="task.assigned_to" sm="6">
                    <small>
                      <strong>Assigned to:</strong> {{ task.assigned_to }}
                    </small>
                  </v-col>
                  <v-col sm="6">
                    <small v-if="task.due_date">
                      <strong>Due:</strong> {{ formatDate(task.due_date) }}
                    </small>
                  </v-col>
                </v-row>
                <v-row v-if="task.tags && task.tags.length > 0" class="mt-2">
                  <v-col>
                    <v-chip
                      v-for="tag in task.tags"
                      :key="tag.id"
                      :text="tag.name"
                      size="x-small"
                      variant="outlined"
                      class="mr-1"
                    />
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </div>
        </v-col>
      </v-row>

      <!-- No Results Message -->
      <v-row v-if="!loading && searchQuery && results.length === 0">
        <v-col cols="12" class="text-center py-8">
          <v-icon size="48" class="mb-4 text-disabled">
            mdi-magnify-off
          </v-icon>
          <p class="text-h6 text-disabled">No results found</p>
          <p class="text-body-2 text-disabled">Try adjusting your search or filters</p>
        </v-col>
      </v-row>
    </v-container>
  </v-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

// State
const searchQuery = ref('')
const showAdvancedFilters = ref(false)
const loading = ref(false)
const results = ref([])
const recentSearches = ref([])
const users = ref([])
const tags = ref([])

// Filter state
const filters = ref({
  status: [],
  priority: [],
  assignedUser: null,
  tags: [],
  startDate: '',
  endDate: '',
  searchType: 'all'
})

// Options
const statusOptions = [
  'To Do',
  'In Progress',
  'Done',
  'Not Started',
  'Completed',
  'On Hold'
]

const priorityOptions = [
  'Low',
  'Medium',
  'High'
]

// Computed
const projectResults = computed(() => {
  return results.value.filter(r => r.type === 'project')
})

const taskResults = computed(() => {
  return results.value.filter(r => r.type === 'task')
})

// Methods
const debouncedSearch = (() => {
  let timeoutId
  return () => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(performSearch, 300)
  }
})()

const performSearch = async () => {
  if (!searchQuery.value.trim() && Object.values(filters.value).every(v => !v || v.length === 0)) {
    results.value = []
    return
  }

  loading.value = true
  try {
    const response = await axios.get('/api/v1/search', {
      params: {
        q: searchQuery.value,
        ...filters.value
      }
    })

    results.value = response.data.results || []

    // Add to recent searches if new search
    if (searchQuery.value && !recentSearches.value.includes(searchQuery.value)) {
      recentSearches.value.unshift(searchQuery.value)
      // Keep only last 10 searches
      if (recentSearches.value.length > 10) {
        recentSearches.value.pop()
      }
      localStorage.setItem('recent-searches', JSON.stringify(recentSearches.value))
    }
  } catch (error) {
    console.error('Search error:', error)
  } finally {
    loading.value = false
  }
}

const clearFilters = () => {
  searchQuery.value = ''
  filters.value = {
    status: [],
    priority: [],
    assignedUser: null,
    tags: [],
    startDate: '',
    endDate: '',
    searchType: 'all'
  }
  results.value = []
}

const removeRecentSearch = (search) => {
  const index = recentSearches.value.indexOf(search)
  if (index > -1) {
    recentSearches.value.splice(index, 1)
    localStorage.setItem('recent-searches', JSON.stringify(recentSearches.value))
  }
}

const quickFilterMyTasks = () => {
  filters.value.status = ['In Progress', 'To Do']
  showAdvancedFilters.value = true
  performSearch()
}

const quickFilterHighPriority = () => {
  filters.value.priority = ['High']
  showAdvancedFilters.value = true
  performSearch()
}

const quickFilterOverdue = () => {
  filters.value.endDate = new Date(Date.now() - 86400000).toISOString().split('T')[0]
  showAdvancedFilters.value = true
  performSearch()
}

const quickFilterInProgress = () => {
  filters.value.status = ['In Progress']
  showAdvancedFilters.value = true
  performSearch()
}

const highlightText = (text) => {
  if (!text || !searchQuery.value) return text
  const regex = new RegExp(`(${searchQuery.value})`, 'gi')
  return text.replace(regex, '<mark>$1</mark>')
}

const getStatusColor = (status) => {
  const colorMap = {
    'To Do': 'default',
    'In Progress': 'warning',
    'Done': 'success',
    'Not Started': 'default',
    'Completed': 'success',
    'On Hold': 'info'
  }
  return colorMap[status] || 'default'
}

const getPriorityColor = (priority) => {
  const colorMap = {
    'Low': 'info',
    'Medium': 'warning',
    'High': 'error'
  }
  return colorMap[priority] || 'default'
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const loadRecentSearches = () => {
  const saved = localStorage.getItem('recent-searches')
  if (saved) {
    try {
      recentSearches.value = JSON.parse(saved)
    } catch (e) {
      console.error('Error loading recent searches:', e)
    }
  }
}

const loadUsers = async () => {
  try {
    const response = await axios.get('/api/v1/users')
    users.value = response.data || []
  } catch (error) {
    console.error('Error loading users:', error)
  }
}

const loadTags = async () => {
  try {
    const response = await axios.get('/api/v1/tags')
    tags.value = response.data || []
  } catch (error) {
    console.error('Error loading tags:', error)
  }
}

// Initialize
onMounted(() => {
  loadRecentSearches()
  loadUsers()
  loadTags()
})
</script>

<style scoped>
.advanced-search-container {
  margin: 20px 0;
}

.search-result-card {
  transition: all 0.3s ease;
}

.search-result-card:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.search-result-card a {
  color: inherit;
  font-weight: 500;
}

.search-result-card a:hover {
  text-decoration: underline;
}

.gap-2 {
  gap: 8px;
}

:deep(mark) {
  background-color: yellow;
  padding: 0 4px;
  border-radius: 2px;
  font-weight: 500;
}

:deep(.dark-mode) mark {
  background-color: #ffd54f;
  color: #000;
}

.text-muted {
  color: rgba(0, 0, 0, 0.54);
}

:deep(.dark) .text-muted {
  color: rgba(255, 255, 255, 0.54);
}

.text-disabled {
  color: rgba(0, 0, 0, 0.38);
}

:deep(.dark) .text-disabled {
  color: rgba(255, 255, 255, 0.38);
}
</style>
