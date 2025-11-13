<template>
  <transition name="theme-fade">
    <v-btn
      :icon="isDark ? 'mdi-moon' : 'mdi-white-balance-sunny'"
      :aria-label="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
      @click="toggleDarkMode"
      class="theme-toggle"
      :ripple="false"
    />
  </transition>
</template>

<script setup>
import { computed, inject } from 'vue'
import { useDarkMode } from '../composables/useDarkMode'

const vuetify = inject('vuetify')
const { isDark, toggleDarkMode } = useDarkMode(vuetify)
</script>

<style scoped>
.theme-toggle {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.theme-toggle:hover {
  transform: scale(1.1) rotate(10deg);
}

.theme-toggle:active {
  transform: scale(0.95);
}

.theme-fade-enter-active,
.theme-fade-leave-active {
  transition: opacity 0.3s ease;
}

.theme-fade-enter-from,
.theme-fade-leave-to {
  opacity: 0;
}
</style>
