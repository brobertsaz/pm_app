import { createApp } from 'vue'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Import components
import ProjectList from './components/ProjectList.vue'
import ProjectForm from './components/ProjectForm.vue'

const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light',
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
})
