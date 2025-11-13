import { ref, onMounted, onUnmounted } from 'vue'

// Import ActionCable (assumes it's available globally or via import)
let ActionCable = window.ActionCable

export function useWebSocket() {
  const connection = ref(null)
  const channels = ref({})
  const connectionStatus = ref('disconnected') // 'disconnected', 'connecting', 'connected'
  const lastHeartbeat = ref(null)
  const reconnectAttempts = ref(0)
  const maxReconnectAttempts = ref(5)
  const reconnectDelay = ref(1000)
  const reconnectTimer = ref(null)

  // Initialize WebSocket connection
  const connect = () => {
    if (connectionStatus.value === 'connected' || connectionStatus.value === 'connecting') {
      return
    }

    connectionStatus.value = 'connecting'

    try {
      connection.value = ActionCable.createConsumer()

      connection.value.addEventListener('open', () => {
        console.log('WebSocket connected')
        connectionStatus.value = 'connected'
        reconnectAttempts.value = 0
        lastHeartbeat.value = Date.now()
      })

      connection.value.addEventListener('close', () => {
        console.log('WebSocket closed')
        connectionStatus.value = 'disconnected'
        attemptReconnect()
      })

      connection.value.addEventListener('error', (error) => {
        console.error('WebSocket error:', error)
        connectionStatus.value = 'disconnected'
        attemptReconnect()
      })

      // Setup heartbeat monitoring
      startHeartbeatMonitor()
    } catch (error) {
      console.error('Failed to connect to WebSocket:', error)
      connectionStatus.value = 'disconnected'
      attemptReconnect()
    }
  }

  // Attempt to reconnect with exponential backoff
  const attemptReconnect = () => {
    if (reconnectAttempts.value >= maxReconnectAttempts.value) {
      console.error('Max reconnection attempts reached')
      return
    }

    reconnectAttempts.value++
    const delay = Math.min(
      reconnectDelay.value * Math.pow(2, reconnectAttempts.value - 1),
      30000 // Max 30 seconds
    )

    console.log(`Attempting to reconnect in ${delay}ms (attempt ${reconnectAttempts.value}/${maxReconnectAttempts.value})`)

    reconnectTimer.value = setTimeout(() => {
      if (connectionStatus.value === 'disconnected') {
        connect()
      }
    }, delay)
  }

  // Start heartbeat monitoring
  const startHeartbeatMonitor = () => {
    const heartbeatInterval = setInterval(() => {
      if (connectionStatus.value === 'connected' && connection.value) {
        lastHeartbeat.value = Date.now()
      }
    }, 30000) // Check every 30 seconds

    return () => clearInterval(heartbeatInterval)
  }

  // Subscribe to a channel
  const subscribe = (channelName, params = {}) => {
    if (!connection.value || connectionStatus.value !== 'connected') {
      console.warn('Cannot subscribe: connection not ready')
      return null
    }

    const channelKey = `${channelName}:${JSON.stringify(params)}`

    if (channels.value[channelKey]) {
      return channels.value[channelKey]
    }

    try {
      const subscription = connection.value.subscriptions.create(
        { channel: channelName, ...params },
        {
          connected() {
            console.log(`Subscribed to ${channelName} with params`, params)
          },

          disconnected() {
            console.log(`Unsubscribed from ${channelName}`)
            delete channels.value[channelKey]
          },

          received(data) {
            handleChannelMessage(channelName, data)
          },

          rejected() {
            console.error(`Subscription rejected for ${channelName}`)
            delete channels.value[channelKey]
          }
        }
      )

      channels.value[channelKey] = subscription
      return subscription
    } catch (error) {
      console.error(`Failed to subscribe to ${channelName}:`, error)
      return null
    }
  }

  // Unsubscribe from a channel
  const unsubscribe = (channelName, params = {}) => {
    const channelKey = `${channelName}:${JSON.stringify(params)}`

    if (channels.value[channelKey]) {
      const subscription = channels.value[channelKey]
      subscription.unsubscribe()
      delete channels.value[channelKey]
      console.log(`Unsubscribed from ${channelKey}`)
    }
  }

  // Handle incoming messages from channels
  const messageHandlers = ref({})

  const handleChannelMessage = (channelName, data) => {
    console.log(`Message from ${channelName}:`, data)

    // Emit events to registered handlers
    if (messageHandlers.value[channelName]) {
      messageHandlers.value[channelName].forEach((handler) => {
        try {
          handler(data)
        } catch (error) {
          console.error(`Error in message handler for ${channelName}:`, error)
        }
      })
    }

    // Also emit a generic 'message' event
    if (messageHandlers.value['message']) {
      messageHandlers.value['message'].forEach((handler) => {
        try {
          handler({ channel: channelName, data })
        } catch (error) {
          console.error('Error in generic message handler:', error)
        }
      })
    }
  }

  // Register message handler for a channel
  const onMessage = (channelName, handler) => {
    if (!messageHandlers.value[channelName]) {
      messageHandlers.value[channelName] = []
    }
    messageHandlers.value[channelName].push(handler)

    // Return unsubscribe function
    return () => {
      const index = messageHandlers.value[channelName].indexOf(handler)
      if (index > -1) {
        messageHandlers.value[channelName].splice(index, 1)
      }
    }
  }

  // Send message to a channel
  const send = (channelName, params = {}, action = 'message', data = {}) => {
    const channelKey = `${channelName}:${JSON.stringify(params)}`
    const subscription = channels.value[channelKey]

    if (!subscription) {
      console.warn(`Cannot send: not subscribed to ${channelKey}`)
      return
    }

    try {
      subscription.send({
        action,
        ...data
      })
    } catch (error) {
      console.error(`Failed to send message to ${channelName}:`, error)
    }
  }

  // Disconnect WebSocket
  const disconnect = () => {
    if (reconnectTimer.value) {
      clearTimeout(reconnectTimer.value)
    }

    // Unsubscribe from all channels
    Object.keys(channels.value).forEach((key) => {
      try {
        channels.value[key].unsubscribe()
      } catch (error) {
        console.error(`Error unsubscribing from ${key}:`, error)
      }
    })
    channels.value = {}

    if (connection.value) {
      try {
        connection.value.disconnect()
      } catch (error) {
        console.error('Error disconnecting:', error)
      }
      connection.value = null
    }

    connectionStatus.value = 'disconnected'
    console.log('WebSocket disconnected')
  }

  // Check connection health
  const isHealthy = () => {
    if (connectionStatus.value !== 'connected') {
      return false
    }

    // Check if we've received a heartbeat in the last 60 seconds
    if (lastHeartbeat.value) {
      const timeSinceHeartbeat = Date.now() - lastHeartbeat.value
      return timeSinceHeartbeat < 60000
    }

    return true
  }

  // Auto-connect on mount and clean up on unmount
  const setupAutoConnect = () => {
    onMounted(() => {
      connect()
    })

    onUnmounted(() => {
      disconnect()
    })
  }

  return {
    connect,
    disconnect,
    subscribe,
    unsubscribe,
    onMessage,
    send,
    connectionStatus,
    lastHeartbeat,
    isHealthy,
    setupAutoConnect,
    channels,
    maxReconnectAttempts,
    reconnectDelay
  }
}

// Project-specific WebSocket composable
export function useProjectWebSocket(projectId) {
  const ws = useWebSocket()
  const projectUpdates = ref(null)
  const activityUpdates = ref([])
  const taskUpdates = ref([])

  // Subscribe to project channel
  const subscribeToProject = () => {
    if (!projectId) {
      console.warn('Project ID is required')
      return
    }

    // Subscribe to project updates
    ws.subscribe('ProjectChannel', { project_id: projectId })

    // Subscribe to activity stream
    ws.subscribe('ActivityChannel', { project_id: projectId })

    // Subscribe to task updates
    ws.subscribe('TaskChannel', { project_id: projectId })

    // Handle project updates
    ws.onMessage('ProjectChannel', (data) => {
      console.log('Project update received:', data)
      projectUpdates.value = data
    })

    // Handle activity updates
    ws.onMessage('ActivityChannel', (data) => {
      console.log('Activity update received:', data)

      if (data.type === 'activity_created') {
        activityUpdates.value.unshift(data.activity)
      } else if (data.type === 'recent_activities') {
        activityUpdates.value = data.activities
      } else if (data.type === 'activities_created') {
        activityUpdates.value.unshift(...data.activities)
      }
    })

    // Handle task updates
    ws.onMessage('TaskChannel', (data) => {
      console.log('Task update received:', data)

      if (data.type === 'task_created') {
        taskUpdates.value.push(data.task)
      } else if (data.type === 'task_updated') {
        const index = taskUpdates.value.findIndex((t) => t.id === data.task.id)
        if (index > -1) {
          taskUpdates.value[index] = data.task
        } else {
          taskUpdates.value.push(data.task)
        }
      } else if (data.type === 'task_deleted') {
        taskUpdates.value = taskUpdates.value.filter((t) => t.id !== data.task_id)
      } else if (data.type === 'task_status_changed') {
        const index = taskUpdates.value.findIndex((t) => t.id === data.task.id)
        if (index > -1) {
          taskUpdates.value[index] = data.task
        }
      } else if (data.type === 'tasks_list') {
        taskUpdates.value = data.tasks
      }
    })
  }

  const unsubscribeFromProject = () => {
    ws.unsubscribe('ProjectChannel', { project_id: projectId })
    ws.unsubscribe('ActivityChannel', { project_id: projectId })
    ws.unsubscribe('TaskChannel', { project_id: projectId })
  }

  const requestProjectUpdate = () => {
    ws.send('ProjectChannel', { project_id: projectId }, 'request_update')
  }

  const requestRecentActivities = () => {
    ws.send('ActivityChannel', { project_id: projectId }, 'request_recent_activities')
  }

  const requestTasksList = () => {
    ws.send('TaskChannel', { project_id: projectId }, 'request_tasks')
  }

  return {
    ...ws,
    subscribeToProject,
    unsubscribeFromProject,
    requestProjectUpdate,
    requestRecentActivities,
    requestTasksList,
    projectUpdates,
    activityUpdates,
    taskUpdates
  }
}

// Global WebSocket composable for dashboard and general updates
export function useDashboardWebSocket() {
  const ws = useWebSocket()
  const allActivities = ref([])
  const allProjects = ref([])

  // Subscribe to global activity stream (all projects)
  const subscribeToGlobalActivity = () => {
    // This would require a GlobalActivityChannel if you want to track all activities
    // For now, we'll use the project-specific channels
  }

  return {
    ...ws,
    subscribeToGlobalActivity,
    allActivities,
    allProjects
  }
}
