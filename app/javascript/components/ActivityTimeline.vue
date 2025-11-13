<template>
  <div v-if="activities.length > 0" class="activity-timeline">
    <div v-for="(activity, index) in activities" :key="activity.id" class="timeline-item">
      <!-- Timeline connector line -->
      <div v-if="index < activities.length - 1" class="timeline-connector"></div>

      <!-- Timeline dot and content -->
      <div class="d-flex gap-4">
        <!-- Icon dot -->
        <div class="timeline-icon-wrapper">
          <v-avatar
            :color="activity.color"
            size="40"
            class="d-flex align-center justify-center"
          >
            <v-icon :icon="activity.icon" color="white" size="24"></v-icon>
          </v-avatar>
        </div>

        <!-- Activity content -->
        <div class="flex-grow-1 timeline-content">
          <div class="d-flex justify-space-between align-start mb-2">
            <div>
              <h4 class="text-subtitle-1 font-weight-medium mb-1">
                {{ activity.description }}
              </h4>
              <div class="d-flex align-center gap-2">
                <v-chip size="small" :color="`${activity.color}20`" text-color="black">
                  {{ activity.trackable_type }}
                </v-chip>
                <span class="text-caption text-grey">
                  {{ formatDate(activity.created_at) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div v-else class="text-center py-8">
    <v-icon size="48" color="grey" class="mb-4">mdi-history</v-icon>
    <p class="text-subtitle-1 text-grey">No activities yet</p>
  </div>
</template>

<script setup>
defineProps({
  activities: {
    type: Array,
    required: true,
    default: () => []
  }
})

const formatDate = (dateString) => {
  if (!dateString) return ''

  const date = new Date(dateString)
  const now = new Date()
  const diffInSeconds = Math.floor((now - date) / 1000)

  if (diffInSeconds < 60) {
    return 'Just now'
  }

  if (diffInSeconds < 3600) {
    const minutes = Math.floor(diffInSeconds / 60)
    return `${minutes}m ago`
  }

  if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600)
    return `${hours}h ago`
  }

  if (diffInSeconds < 604800) {
    const days = Math.floor(diffInSeconds / 86400)
    return `${days}d ago`
  }

  return date.toLocaleDateString()
}
</script>

<style scoped>
.activity-timeline {
  position: relative;
  padding-left: 12px;
}

.timeline-item {
  position: relative;
  padding-bottom: 24px;
}

.timeline-item:last-child {
  padding-bottom: 0;
}

.timeline-connector {
  position: absolute;
  left: 19px;
  top: 48px;
  bottom: 0;
  width: 2px;
  background: linear-gradient(
    to bottom,
    rgba(103, 58, 183, 0.3),
    rgba(103, 58, 183, 0)
  );
}

.timeline-icon-wrapper {
  flex-shrink: 0;
  position: relative;
  z-index: 2;
}

.timeline-content {
  padding-top: 4px;
}

.activity-timeline :deep(.v-chip) {
  font-size: 0.75rem;
}
</style>
