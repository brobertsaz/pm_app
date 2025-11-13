import { ref, watch } from 'vue'

const DARK_MODE_KEY = 'pm-app-dark-mode'

export function useDarkMode(vuetify) {
  const isDark = ref(false)

  // Initialize dark mode from localStorage
  const initializeDarkMode = () => {
    const savedDarkMode = localStorage.getItem(DARK_MODE_KEY)

    if (savedDarkMode !== null) {
      isDark.value = JSON.parse(savedDarkMode)
    } else {
      // Check system preference
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }

    applyTheme()
  }

  // Apply theme to Vuetify
  const applyTheme = () => {
    if (vuetify && vuetify.framework) {
      vuetify.framework.theme.dark = isDark.value
    } else if (vuetify && vuetify.theme) {
      // For newer Vuetify versions
      vuetify.global.name = isDark.value ? 'dark' : 'light'
    }

    // Apply to document for CSS custom properties
    if (isDark.value) {
      document.documentElement.setAttribute('data-theme', 'dark')
    } else {
      document.documentElement.removeAttribute('data-theme')
    }
  }

  // Toggle dark mode
  const toggleDarkMode = () => {
    isDark.value = !isDark.value
    localStorage.setItem(DARK_MODE_KEY, JSON.stringify(isDark.value))
    applyTheme()
  }

  // Watch for changes
  watch(isDark, () => {
    applyTheme()
  })

  return {
    isDark,
    toggleDarkMode,
    initializeDarkMode,
    applyTheme
  }
}
