<template>
  <v-card class="comment-thread">
    <v-card-title>
      <span class="text-h6">Comments ({{ comments.length }})</span>
    </v-card-title>

    <v-divider></v-divider>

    <!-- Comments List -->
    <v-card-text v-if="comments.length > 0" class="comments-list pa-0">
      <div v-for="comment in comments" :key="comment.id" class="comment-item">
        <v-list-item>
          <template #prepend>
            <v-avatar color="primary" :size="40">
              {{ getInitials(comment.user.email) }}
            </v-avatar>
          </template>

          <v-list-item-title>{{ comment.user.email }}</v-list-item-title>
          <v-list-item-subtitle>{{ formatDate(comment.created_at) }}</v-list-item-subtitle>

          <template #append v-if="isCommentOwner(comment)">
            <v-btn
              icon
              size="small"
              variant="text"
              @click="deleteComment(comment.id)"
              :loading="deletingCommentId === comment.id"
            >
              <v-icon>mdi-delete</v-icon>
            </v-btn>
          </template>
        </v-list-item>

        <div class="comment-body px-4 pb-4">
          {{ comment.body }}
        </div>
        <v-divider></v-divider>
      </div>
    </v-card-text>

    <!-- No Comments Message -->
    <v-card-text v-else class="text-center py-8">
      <v-icon size="48" class="mb-2 opacity-50">mdi-comment-outline</v-icon>
      <p class="text-subtitle-2 opacity-75">No comments yet. Be the first to comment!</p>
    </v-card-text>

    <!-- Add Comment Form -->
    <v-divider></v-divider>

    <v-card-text class="add-comment pa-4">
      <v-textarea
        v-model="newComment"
        label="Add a comment..."
        placeholder="Share your thoughts..."
        rows="3"
        outlined
        :disabled="submitting"
        @keydown.ctrl.enter="submitComment"
        @keydown.meta.enter="submitComment"
      ></v-textarea>

      <div class="d-flex justify-end gap-2 mt-2">
        <v-btn
          variant="text"
          @click="newComment = ''"
          :disabled="submitting"
        >
          Cancel
        </v-btn>
        <v-btn
          color="primary"
          @click="submitComment"
          :loading="submitting"
          :disabled="!newComment.trim()"
        >
          <v-icon start>mdi-send</v-icon>
          Comment
        </v-btn>
      </div>
    </v-card-text>

    <!-- Loading State -->
    <v-overlay v-if="loading" absolute>
      <v-progress-circular indeterminate></v-progress-circular>
    </v-overlay>
  </v-card>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import axios from 'axios'

const props = defineProps({
  commentableType: {
    type: String,
    required: true,
    validator: value => ['Project', 'Task'].includes(value)
  },
  commentableId: {
    type: Number,
    required: true
  }
})

const comments = reactive([])
const newComment = ref('')
const loading = ref(false)
const submitting = ref(false)
const deletingCommentId = ref(null)
const currentUserId = ref(null)

const getApiPath = () => {
  const typeMap = {
    'Project': 'projects',
    'Task': 'tasks'
  }
  return `/api/v1/${typeMap[props.commentableType]}/${props.commentableId}/comments`
}

const getInitials = (email) => {
  return email.split('@')[0].substring(0, 2).toUpperCase()
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffInMs = now - date
  const diffInMinutes = Math.floor(diffInMs / 60000)
  const diffInHours = Math.floor(diffInMs / 3600000)
  const diffInDays = Math.floor(diffInMs / 86400000)

  if (diffInMinutes < 1) return 'just now'
  if (diffInMinutes < 60) return `${diffInMinutes}m ago`
  if (diffInHours < 24) return `${diffInHours}h ago`
  if (diffInDays < 7) return `${diffInDays}d ago`

  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
  })
}

const isCommentOwner = (comment) => {
  return currentUserId.value === comment.user.id
}

const fetchComments = async () => {
  loading.value = true
  try {
    const response = await axios.get(getApiPath())
    comments.length = 0
    comments.push(...response.data)
  } catch (error) {
    console.error('Error fetching comments:', error)
  } finally {
    loading.value = false
  }
}

const submitComment = async () => {
  if (!newComment.value.trim()) return

  submitting.value = true
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const config = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    const response = await axios.post(
      getApiPath(),
      { comment: { body: newComment.value } },
      config
    )

    comments.push(response.data)
    newComment.value = ''

    // Scroll to bottom
    setTimeout(() => {
      const container = document.querySelector('.comments-list')
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    }, 0)
  } catch (error) {
    console.error('Error posting comment:', error)
  } finally {
    submitting.value = false
  }
}

const deleteComment = async (commentId) => {
  if (!confirm('Are you sure you want to delete this comment?')) return

  deletingCommentId.value = commentId
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const config = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    await axios.delete(
      `${getApiPath()}/${commentId}`,
      config
    )

    const index = comments.findIndex(c => c.id === commentId)
    if (index > -1) {
      comments.splice(index, 1)
    }
  } catch (error) {
    console.error('Error deleting comment:', error)
  } finally {
    deletingCommentId.value = null
  }
}

const getCurrentUser = async () => {
  try {
    const response = await axios.get('/api/v1/current_user')
    currentUserId.value = response.data.id
  } catch (error) {
    console.error('Error fetching current user:', error)
  }
}

onMounted(() => {
  fetchComments()
  getCurrentUser()
})
</script>

<style scoped>
.comment-thread {
  margin-bottom: 24px;
}

.comments-list {
  max-height: 400px;
  overflow-y: auto;
  background-color: rgba(0, 0, 0, 0.02);
}

.comment-item {
  transition: background-color 0.2s;

  &:hover {
    background-color: rgba(0, 0, 0, 0.04);
  }
}

.comment-body {
  color: rgba(0, 0, 0, 0.87);
  line-height: 1.6;
  word-break: break-word;
}

.add-comment {
  background-color: rgba(0, 0, 0, 0.02);
}

.gap-2 {
  gap: 8px;
}

.opacity-50 {
  opacity: 0.5;
}

.opacity-75 {
  opacity: 0.75;
}
</style>
