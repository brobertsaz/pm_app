# Real-Time Updates Setup Guide

This document outlines the Action Cable implementation for real-time updates in the PM App.

## Overview

Real-time updates have been implemented using Rails Action Cable with WebSocket support. The system broadcasts changes to projects, tasks, and activities in real-time to all connected clients.

## Components Created

### Backend (Ruby/Rails)

#### 1. Action Cable Channels

**File: `app/channels/project_channel.rb`**
- Broadcasts project creation, updates, and deletions
- Subscribes clients to specific project updates
- Methods:
  - `broadcast_project_created(project)` - Broadcast when project is created
  - `broadcast_project_updated(project)` - Broadcast when project is updated
  - `broadcast_project_deleted(project)` - Broadcast when project is deleted

**File: `app/channels/activity_channel.rb`**
- Broadcasts activity stream updates
- Broadcasts when new activities are created in a project
- Methods:
  - `broadcast_activity(project, activity)` - Broadcast single activity
  - `broadcast_activities(project, activities)` - Broadcast multiple activities

**File: `app/channels/task_channel.rb`**
- Broadcasts task updates (create, update, delete, status changes)
- Methods:
  - `broadcast_task_created(project, task)` - Broadcast task creation
  - `broadcast_task_updated(project, task)` - Broadcast task updates
  - `broadcast_task_deleted(project, task)` - Broadcast task deletion
  - `broadcast_task_status_changed(project, task, old_status)` - Broadcast status changes

#### 2. Background Job

**File: `app/jobs/broadcast_activity_job.rb`**
- Async job to broadcast activities without blocking the request
- Queued when activities are created via callbacks
- Prevents performance degradation in high-traffic scenarios

#### 3. Model Updates

**Modified: `app/models/activity.rb`**
- Added `after_create :broadcast_activity_created` callback
- Queues `BroadcastActivityJob` to broadcast activities

**Modified: `app/models/project.rb`**
- Added callbacks:
  - `after_create :broadcast_project_created`
  - `after_update :broadcast_project_updated`
  - `before_destroy :broadcast_project_deleted`

**Modified: `app/models/task.rb`**
- Added callbacks:
  - `after_create :broadcast_task_created`
  - `after_update :broadcast_task_updated`
  - `before_destroy :broadcast_task_deleted`
- Status changes are detected and broadcast separately

#### 4. Connection Authentication

**Modified: `app/channels/application_cable/connection.rb`**
- Authenticates WebSocket connections using Devise
- Only authenticated users can connect
- Identifies connections by current user

#### 5. Serializers

**File: `app/serializers/activity_serializer.rb`**
- Serializes activities for transmission over WebSocket

**File: `app/serializers/project_serializer.rb`**
- Serializes projects with metadata (tasks count, completion percentage, etc.)

**File: `app/serializers/task_serializer.rb`**
- Serializes tasks with project and user information

### Frontend (Vue 3 / JavaScript)

#### 1. WebSocket Composables

**File: `app/javascript/composables/useWebSocket.js`**

Main composable with features:
- `connect()` - Establish WebSocket connection
- `disconnect()` - Close WebSocket and unsubscribe from channels
- `subscribe(channelName, params)` - Subscribe to a channel
- `unsubscribe(channelName, params)` - Unsubscribe from a channel
- `onMessage(channelName, handler)` - Register message handler
- `send(channelName, params, action, data)` - Send message to channel

Features:
- **Automatic Reconnection**: Implements exponential backoff retry logic
  - Max 5 reconnection attempts (configurable)
  - Initial delay: 1000ms
  - Max delay: 30000ms
- **Connection Health Check**: Monitors heartbeat to detect stale connections
- **Error Handling**: Graceful degradation on connection failures
- **Channel Management**: Maintains subscriptions and message handlers

Exported composables:
- `useWebSocket()` - Base WebSocket management
- `useProjectWebSocket(projectId)` - Project-specific updates
- `useDashboardWebSocket()` - Dashboard-wide updates

#### 2. Component Updates

**Modified: `app/javascript/components/Dashboard.vue`**
- Integrated `useWebSocket` composable
- Real-time activity stream updates
- Displays connection status
- Auto-subscribes to all project activities from dashboard data
- Features:
  - Live activity count updates
  - Automatic subscription to project activity channels
  - Connection status indicator

**Modified: `app/javascript/components/KanbanBoard.vue`**
- Integrated `useWebSocket` composable
- Real-time task updates (create, update, delete, status changes)
- Automatic re-subscription when project filter changes
- Features:
  - Snackbar notifications for real-time task changes
  - Live task count updates per status
  - Handles task creation by other users
  - Detects and notifies on task status changes
  - Removed deleted tasks automatically

### Configuration

#### Routes

**Modified: `config/routes.rb`**
```ruby
mount ActionCable.server => '/cable'
```
- Mounts ActionCable at `/cable` endpoint

#### Action Cable Configuration

**File: `config/cable.yml`** (Already configured)
```yaml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: pm_app_production
```

- Development: Uses async adapter (in-process, suitable for single server)
- Production: Uses Redis for multi-server deployments

#### JavaScript Configuration

**Modified: `app/javascript/application.js`**
- Imports `@rails/actioncable`
- Exposes `ActionCable` globally via `window.ActionCable`
- Available to all Vue components and composables

## Real-Time Flow

### Project Update Flow
1. User updates a project
2. `Project.after_update` callback triggers
3. `ProjectChannel.broadcast_project_updated()` broadcasts to all subscribed clients
4. Vue components receive update via WebSocket
5. Dashboard/components re-render with new data

### Task Update Flow
1. User updates a task (status, title, etc.)
2. `Task.after_update` callback triggers
3. Detects if status changed (special handling)
4. `TaskChannel.broadcast_task_updated()` broadcasts to subscribed clients
5. Kanban board updates task in real-time
6. Other users see the change immediately

### Activity Flow (Async)
1. Activity is created (via model callback)
2. `Activity.after_create` queues `BroadcastActivityJob`
3. Background job fetches and broadcasts the activity
4. Dashboard subscribes to `ActivityChannel`
5. Activity appears in real-time activity stream

## Usage Examples

### Subscribing to Project Updates

```javascript
import { useProjectWebSocket } from '@/composables/useWebSocket'

const { subscribeToProject, projectUpdates } = useProjectWebSocket(projectId)

onMounted(() => {
  subscribeToProject()
})
```

### Handling Real-Time Task Updates

```javascript
const { subscribe, onMessage } = useWebSocket()

onMounted(() => {
  ws.connect()
  subscribe('TaskChannel', { project_id: projectId })

  ws.onMessage('TaskChannel', (data) => {
    if (data.type === 'task_updated') {
      // Handle task update
      updateLocalTask(data.task)
    }
  })
})
```

### Manual Channel Operations

```javascript
const ws = useWebSocket()

ws.connect()
ws.subscribe('ActivityChannel', { project_id: 123 })
ws.send('ActivityChannel', { project_id: 123 }, 'request_recent_activities')
```

## Environment Setup

### Required Gems
```ruby
gem 'rails', '~> 7.2.0'  # Includes ActionCable
gem 'devise'              # For authentication
gem 'jsbundling-rails'    # For JavaScript bundling
```

### Required NPM Packages
```bash
npm install @rails/actioncable
```

### Production Setup

#### Redis Configuration
For production deployments, Redis must be configured:

1. Install Redis:
   ```bash
   # On Ubuntu
   sudo apt-get install redis-server

   # On macOS
   brew install redis
   ```

2. Configure REDIS_URL environment variable:
   ```bash
   export REDIS_URL="redis://localhost:6379/1"
   ```

3. Start Redis:
   ```bash
   redis-server
   ```

#### Nginx Configuration (Production)
Add to your Nginx configuration for WebSocket support:

```nginx
# WebSocket upgrade headers
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream puma {
    server unix:///var/www/pm_app/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://puma;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /cable {
        proxy_pass http://puma;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### Puma Configuration (Production)
Ensure Puma is configured with:
- Multiple threads for handling concurrent WebSocket connections
- Sufficient worker processes

```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

allow_concurrency = true
```

## Reconnection Logic

The `useWebSocket` composable implements intelligent reconnection:

1. **Exponential Backoff**: Waits longer between each retry attempt
   - Attempt 1: 1 second
   - Attempt 2: 2 seconds
   - Attempt 3: 4 seconds
   - Attempt 4: 8 seconds
   - Attempt 5: 16 seconds
   - Max: 30 seconds

2. **Max Attempts**: 5 attempts by default (configurable via `maxReconnectAttempts`)

3. **Health Checks**: Monitors connection heartbeat every 30 seconds

4. **Graceful Degradation**: App continues to function with polling if WebSocket fails

## Error Handling

### Connection Errors
- Logged to console
- Automatic reconnection attempts
- User can still interact with app (polling fallback possible)

### Channel Subscription Errors
- Logged and subscription rejected
- User notified via snackbar
- Can retry subscription

### Message Processing Errors
- Individual message errors don't crash the connection
- Errors logged to console
- Other messages continue processing

## Performance Considerations

1. **Background Jobs**: Activities are broadcast asynchronously to prevent blocking
2. **Channel Filtering**: Clients only receive updates for projects they're viewing
3. **Message Throttling**: Rapid updates are individual messages (not batched)
4. **Memory**: Connection maintains only current subscriptions
5. **CPU**: Single-threaded JavaScript handles multiple channels efficiently

## Testing

### Manual Testing
1. Open the app in multiple browser windows
2. Create/update projects, tasks, or activities in one window
3. Verify real-time updates in other windows

### WebSocket Debugging
- Open browser DevTools Network tab
- Filter by WS protocol
- Inspect WebSocket frames to see messages

## Troubleshooting

### Connection Issues
- Check Redis is running (production)
- Verify `/cable` endpoint is accessible
- Check browser console for errors
- Verify user is authenticated (check Devise session)

### Updates Not Appearing
- Check subscriptions in browser console: `window.ActionCable.subscriptions.subscriptions`
- Verify correct project_id in subscription params
- Check Rails logs for broadcast messages

### Performance Issues
- Monitor number of active connections
- Check Redis memory usage (production)
- Verify background job queue is processing

## Future Enhancements

1. **Comment Updates**: Add real-time comment streaming
2. **User Presence**: Track which users are viewing which projects
3. **Typing Indicators**: Show when users are typing
4. **Notification Badges**: Real-time notification counts
5. **Selective Broadcasting**: Only broadcast to project members
6. **Message Compression**: Compress large messages for bandwidth optimization
