import { createApp } from 'vue'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Import ActionCable
import * as ActionCable from '@rails/actioncable'

// Make ActionCable globally available
window.ActionCable = ActionCable

// Import composables
import { useDarkMode } from './composables/useDarkMode'

// Import components
import ProjectList from './components/ProjectList.vue'
import ProjectForm from './components/ProjectForm.vue'
import KanbanBoard from './components/KanbanBoard.vue'
import Dashboard from './components/Dashboard.vue'
import Calendar from './components/Calendar.vue'
import ExportMenu from './components/ExportMenu.vue'
import ThemeToggle from './components/ThemeToggle.vue'
import AdvancedSearch from './components/AdvancedSearch.vue'

// Determine initial theme from localStorage or system preference
const DARK_MODE_KEY = 'pm-app-dark-mode'
let initialDarkMode = false

const savedDarkMode = localStorage.getItem(DARK_MODE_KEY)
if (savedDarkMode !== null) {
  initialDarkMode = JSON.parse(savedDarkMode)
} else {
  // Check system preference
  initialDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches
}

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: initialDarkMode ? 'dark' : 'light',
    themes: {
      light: {
        colors: {
          primary: '#1976D2',
          secondary: '#424242',
          accent: '#82B1FF',
          error: '#FF5252',
          info: '#2196F3',
          success: '#4CAF50',
          warning: '#FFC107',
        },
      },
      dark: {
        colors: {
          primary: '#2196F3',
          secondary: '#424242',
          accent: '#FF4081',
          error: '#FF5252',
          info: '#2196F3',
          success: '#4CAF50',
          warning: '#FB8C00',
        },
      },
    },
  },
})

document.addEventListener('DOMContentLoaded', () => {
  // Mount ProjectList component
  const projectListElement = document.getElementById('project-list-app')
  if (projectListElement) {
    const app = createApp(ProjectList)
    app.use(vuetify)
    app.mount('#project-list-app')
  }

  // Mount ProjectForm component
  const projectFormElement = document.getElementById('project-form-app')
  if (projectFormElement) {
    const app = createApp(ProjectForm)
    app.use(vuetify)
    app.mount('#project-form-app')
  }

  // Mount KanbanBoard component
  const kanbanElement = document.getElementById('kanban-app')
  if (kanbanElement) {
    const app = createApp(KanbanBoard)
    app.use(vuetify)
    app.mount('#kanban-app')
  }

  // Mount Dashboard component
  const dashboardElement = document.getElementById('dashboard-app')
  if (dashboardElement) {
    const app = createApp(Dashboard)
    app.use(vuetify)
    app.mount('#dashboard-app')
  }

  // Mount Calendar component
  const calendarElement = document.getElementById('calendar-app')
  if (calendarElement) {
    const app = createApp(Calendar)
    app.use(vuetify)
    app.mount('#calendar-app')
  }

  // Mount ExportMenu component (if used globally)
  const exportMenuElement = document.getElementById('export-menu-app')
  if (exportMenuElement) {
    const app = createApp(ExportMenu)
    app.use(vuetify)
    app.mount('#export-menu-app')
  }

  // Mount ThemeToggle component
  const themeToggleElement = document.getElementById('theme-toggle-app')
  if (themeToggleElement) {
    const app = createApp(ThemeToggle)
    app.use(vuetify)
    app.mount('#theme-toggle-app')
  }

  // Mount AdvancedSearch component
  const advancedSearchElement = document.getElementById('advanced-search-app')
  if (advancedSearchElement) {
    const app = createApp(AdvancedSearch)
    app.use(vuetify)
    app.mount('#advanced-search-app')
  }

  // Initialize dark mode from localStorage
  const { initializeDarkMode } = useDarkMode(vuetify)
  initializeDarkMode()
})
