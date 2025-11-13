# PM App - Enterprise-Grade Project Management Application 🚀

A modern, full-stack project management powerhouse built with Ruby on Rails 7.2 and Vue.js 3. This is not just another PM tool - it's a **complete project management ecosystem** with real-time collaboration, advanced analytics, and enterprise features.

## 🌟 Overview

PM App is a comprehensive project management solution featuring real-time updates, AI-powered analytics, team collaboration, time tracking, and a stunning Material Design interface. Built for scale and designed for productivity.

## 🛠 Tech Stack

### Backend
- **Ruby**: 3.3.6
- **Rails**: 7.2.3
- **Database**: PostgreSQL (with full-text search)
- **Authentication**: Devise 4.9
- **Authorization**: Pundit (policy-based)
- **Background Jobs**: Sidekiq 7.0 + Redis
- **Real-time**: Action Cable + WebSockets
- **File Storage**: Active Storage
- **PDF Generation**: WickedPDF
- **API**: RESTful JSON API v1

### Frontend
- **Vue.js**: 3.5.12 (Composition API)
- **Vuetify**: 3.7.4 (Material Design 3)
- **Axios**: 1.7.7 (HTTP client)
- **Icons**: Material Design Icons (@mdi/font)
- **Build Tool**: esbuild (lightning fast)
- **Real-time**: ActionCable client
- **State Management**: Vue 3 Composition API
- **Charts**: Chart.js integration

### Development & DevOps
- **Testing**: RSpec, FactoryBot, Faker, Capybara
- **Forms**: SimpleForm
- **Templating**: HAML
- **Pagination**: Kaminari
- **CSS**: SCSS with modern utilities
- **Email Preview**: Letter Opener (dev)
- **Job Scheduler**: Sidekiq Scheduler

## ✨ Features

### 🎯 Core Project Management
- ✅ Full CRUD operations for projects
- ✅ Project status tracking (Not Started, In Progress, Completed, On Hold)
- ✅ Priority levels (Low, Medium, High)
- ✅ Due date management with overdue detection
- ✅ User ownership and granular permissions
- ✅ Progress tracking with automatic completion percentages
- ✅ Project templates for rapid project creation
- ✅ File attachments with drag-and-drop upload
- ✅ Activity timeline for complete audit trail

### 📋 Advanced Task Management
- ✅ Full CRUD operations within projects
- ✅ Task status workflow (To Do, In Progress, Done)
- ✅ Task priorities and due dates
- ✅ Drag-and-drop task positioning
- ✅ Task assignment to team members
- ✅ Subtask support with checklists
- ✅ File attachments per task
- ✅ Time tracking with detailed logging
- ✅ Comments and discussions on tasks

### 🎨 Modern UI/UX
- ✅ **Kanban Board** - Drag-and-drop task management across columns
- ✅ **Dashboard** - Real-time analytics and project overview
- ✅ **Calendar View** - Visual deadline management
- ✅ **Dark Mode** - Beautiful dark theme with smooth transitions
- ✅ **Responsive Design** - Perfect on desktop, tablet, and mobile
- ✅ **Material Design 3** - Latest design system from Google
- ✅ **Smooth Animations** - Delightful micro-interactions
- ✅ **Advanced Search** - Lightning-fast search with filters

### 👥 Team Collaboration
- ✅ **Project Members** - Add team members with role-based access
- ✅ **Roles**: Owner, Admin, Member, Viewer
- ✅ **Comments System** - Threaded discussions on projects and tasks
- ✅ **@Mentions** - Tag team members in comments
- ✅ **Activity Feed** - Real-time activity stream
- ✅ **User Avatars** - Visual team member identification

### ⚡ Real-time Features
- ✅ **WebSocket Updates** - Instant updates across all clients
- ✅ **Live Activity Feed** - See changes as they happen
- ✅ **Real-time Kanban** - Tasks update across all browsers
- ✅ **Live Notifications** - Instant alerts for mentions and assignments
- ✅ **Auto-reconnection** - Resilient WebSocket with exponential backoff
- ✅ **Optimistic UI** - Instant feedback with server sync

### 📊 Analytics & Reporting
- ✅ **Project Performance Dashboard** - Completion rates and metrics
- ✅ **Time Tracking Reports** - Hours logged by project/user
- ✅ **Team Productivity Analytics** - Member performance insights
- ✅ **Burndown Charts** - Sprint progress visualization
- ✅ **Custom Date Ranges** - Flexible reporting periods
- ✅ **CSV/PDF Exports** - Professional reports
- ✅ **Visual Charts** - Beautiful data visualization

### 🏷️ Organization & Discovery
- ✅ **Tags System** - Color-coded labels for organization
- ✅ **Advanced Search** - Full-text search with highlighting
- ✅ **Smart Filters** - Filter by status, priority, tags, dates
- ✅ **Recent Searches** - Quick access to previous queries
- ✅ **Quick Filters** - One-click common searches
- ✅ **Project Templates** - Reusable project blueprints

### ⏱️ Time Management
- ✅ **Time Tracking** - Log hours per task
- ✅ **Time Reports** - Detailed time analytics
- ✅ **Billable Hours** - Track client work
- ✅ **Daily Summaries** - Time logged per day
- ✅ **User Timesheets** - Individual time reports
- ✅ **Project Time Budgets** - Track against estimates

### 📧 Notifications & Alerts
- ✅ **Email Notifications** - Beautiful HTML emails
- ✅ **Task Assignments** - Instant email alerts
- ✅ **Deadline Reminders** - 24-hour advance warnings
- ✅ **Overdue Alerts** - Automatic overdue notifications
- ✅ **Daily Digests** - Daily summary emails (scheduled)
- ✅ **Comment Notifications** - Email on @mentions
- ✅ **Background Processing** - Async email delivery with Sidekiq

### 📅 Calendar & Scheduling
- ✅ **Interactive Calendar** - Month view with all deadlines
- ✅ **Color-coded Events** - Priority-based coloring
- ✅ **Project Filtering** - View specific project timelines
- ✅ **Date Navigation** - Easy month-to-month browsing
- ✅ **Event Details** - Click dates to see all tasks/projects

### 📤 Export & Integration
- ✅ **CSV Exports** - Projects, tasks, time entries
- ✅ **PDF Reports** - Professional project reports
- ✅ **Comprehensive Reports** - Full project summaries with tasks
- ✅ **Time Entry Exports** - Billing and timesheet exports
- ✅ **Custom Date Ranges** - Export specific time periods

### 🔐 Security & Authorization
- ✅ **Devise Authentication** - Industry-standard auth
- ✅ **Pundit Authorization** - Fine-grained access control
- ✅ **Policy-based Permissions** - Role-based access
- ✅ **User-scoped Data** - Complete data isolation
- ✅ **CSRF Protection** - Secure forms and API
- ✅ **Encrypted Passwords** - bcrypt encryption

### 🎭 Templates & Automation
- ✅ **Project Templates** - Create reusable project structures
- ✅ **Template Library** - Public and private templates
- ✅ **Quick Instantiation** - One-click project creation
- ✅ **Template from Project** - Save existing projects as templates
- ✅ **Automated Task Creation** - Tasks auto-created from templates

## 🚀 Installation

### Prerequisites
- Ruby 3.3.6
- PostgreSQL 12+
- Redis 6+ (for Sidekiq and Action Cable)
- Node.js 18+ and npm
- Bundler 2.7+

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pm_app
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Setup database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   bundle exec rails db:seed  # Optional: seed sample data
   ```

4. **Build assets**
   ```bash
   npm run build
   npm run build:css
   ```

5. **Start Redis (required for Sidekiq and Action Cable)**
   ```bash
   redis-server
   ```

## 💻 Development

### Running the application

**Option 1: Use Foreman (Recommended)**
```bash
bundle exec foreman start -f Procfile.dev
```

This starts all services:
- Rails server (port 3000)
- JavaScript build watcher
- CSS build watcher
- Sidekiq background jobs
- Redis (if configured in Procfile)

**Option 2: Run services individually**

Terminal 1 - Rails server:
```bash
bundle exec rails server
```

Terminal 2 - JavaScript build (watch mode):
```bash
npm run build -- --watch
```

Terminal 3 - CSS build (watch mode):
```bash
npm run build:css -- --watch
```

Terminal 4 - Sidekiq (background jobs):
```bash
bundle exec sidekiq
```

Terminal 5 - Redis:
```bash
redis-server
```

### Running tests

```bash
bundle exec rspec
```

### Email preview (development)

Open emails in browser:
```bash
open http://localhost:3000/letter_opener
```

## 📊 Database Schema

### Core Tables

**Projects**
- `id`, `name`, `description`, `status`, `priority`, `due_date`
- `user_id` (owner), `created_at`, `updated_at`

**Tasks**
- `id`, `title`, `description`, `status`, `priority`, `due_date`
- `project_id`, `user_id` (assignee), `position`
- `created_at`, `updated_at`

**Users** (Devise)
- `id`, `email`, `encrypted_password`
- Sign-in tracking, reset tokens
- `created_at`, `updated_at`

### Collaboration Tables

**ProjectMembers**
- `id`, `project_id`, `user_id`, `role`
- Unique index on `[project_id, user_id]`

**Comments**
- `id`, `body`, `commentable_type`, `commentable_id` (polymorphic)
- `user_id`, `created_at`, `updated_at`

**Activities**
- `id`, `trackable_type`, `trackable_id` (polymorphic)
- `action`, `user_id`, `project_id`, `metadata` (jsonb)

### Organization Tables

**Tags**
- `id`, `name`, `color`, `project_id`
- Unique index on `[project_id, name]`

**Taggings**
- `id`, `tag_id`, `taggable_type`, `taggable_id` (polymorphic)

### Time Tracking Tables

**TimeEntries**
- `id`, `task_id`, `user_id`, `hours`, `description`, `logged_date`

### Templates

**ProjectTemplates**
- `id`, `name`, `description`, `is_public`, `user_id`

**TemplateTasks**
- `id`, `title`, `description`, `status`, `priority`, `position`
- `project_template_id`

### File Storage

**ActiveStorage** (Blobs, Attachments)
- Managed by Rails Active Storage
- Supports project and task file attachments

## 🌐 API Endpoints

### Authentication
All API endpoints require authentication via Devise session.

### Projects API
```
GET    /api/v1/projects              # List all user projects
GET    /api/v1/projects/:id          # Get project details
POST   /api/v1/projects              # Create project
PUT    /api/v1/projects/:id          # Update project
DELETE /api/v1/projects/:id          # Delete project
```

### Tasks API
```
GET    /api/v1/projects/:project_id/tasks       # List tasks
GET    /api/v1/projects/:project_id/tasks/:id   # Get task
POST   /api/v1/projects/:project_id/tasks       # Create task
PUT    /api/v1/projects/:project_id/tasks/:id   # Update task
DELETE /api/v1/projects/:project_id/tasks/:id   # Delete task
```

### Comments API
```
GET    /api/v1/projects/:id/comments            # List project comments
POST   /api/v1/projects/:id/comments            # Create comment
DELETE /api/v1/projects/:id/comments/:id        # Delete comment
```

### Files API
```
GET    /api/v1/projects/:id/files               # List files
POST   /api/v1/projects/:id/files               # Upload files
DELETE /api/v1/projects/:id/files/:id           # Delete file
GET    /api/v1/projects/:id/files/:id/download  # Download file
```

### Time Tracking API
```
GET    /api/v1/projects/:pid/tasks/:tid/time_entries         # List entries
POST   /api/v1/projects/:pid/tasks/:tid/time_entries         # Create entry
PUT    /api/v1/projects/:pid/tasks/:tid/time_entries/:id     # Update entry
DELETE /api/v1/projects/:pid/tasks/:tid/time_entries/:id     # Delete entry
GET    /api/v1/projects/:pid/tasks/:tid/time_entries/summary # Time summary
```

### Tags API
```
GET    /api/v1/projects/:id/tags     # List project tags
POST   /api/v1/projects/:id/tags     # Create tag
PUT    /api/v1/projects/:id/tags/:id # Update tag
DELETE /api/v1/projects/:id/tags/:id # Delete tag
GET    /api/v1/tags                  # List all user tags
```

### Team API
```
GET    /api/v1/projects/:id/project_members     # List members
POST   /api/v1/projects/:id/project_members     # Add member
PUT    /api/v1/projects/:id/project_members/:id # Update role
DELETE /api/v1/projects/:id/project_members/:id # Remove member
```

### Activities API
```
GET    /api/v1/activities?project_id=:id  # List activities (paginated)
GET    /api/v1/activities?user_id=:id     # User activities
```

### Templates API
```
GET    /api/v1/project_templates               # List user templates
GET    /api/v1/project_templates/public        # List public templates
POST   /api/v1/project_templates               # Create template
PUT    /api/v1/project_templates/:id           # Update template
DELETE /api/v1/project_templates/:id           # Delete template
POST   /api/v1/project_templates/:id/instantiate  # Create project from template
POST   /api/v1/project_templates/from_project    # Save project as template
```

### Search API
```
GET    /api/v1/search?q=query&status[]=...&priority[]=...  # Advanced search
```

### Calendar API
```
GET    /api/v1/calendar/events?start_date=...&end_date=...  # Calendar events
```

### Analytics API
```
GET    /analytics/project_performance   # Project metrics
GET    /analytics/time_reports          # Time tracking reports
GET    /analytics/team_productivity     # Team statistics
GET    /analytics/burndown_chart        # Burndown data
```

### Export API
```
GET    /exports/projects           # Export all projects (CSV)
GET    /exports/projects/:id       # Export project (PDF)
GET    /exports/project_report?project_id=:id  # Full report (PDF)
GET    /exports/tasks              # Export all tasks (CSV)
GET    /exports/time_entries       # Export time entries (CSV)
```

## 🔌 Real-time WebSocket Channels

### Project Channel
```javascript
// Subscribe to project updates
consumer.subscriptions.create({ channel: "ProjectChannel", project_id: 1 })
```

### Task Channel
```javascript
// Subscribe to task updates
consumer.subscriptions.create({ channel: "TaskChannel", project_id: 1 })
```

### Activity Channel
```javascript
// Subscribe to activity stream
consumer.subscriptions.create({ channel: "ActivityChannel", project_id: 1 })
```

### Comment Channel
```javascript
// Subscribe to comments
consumer.subscriptions.create({ channel: "CommentChannel", commentable_type: "Project", commentable_id: 1 })
```

## 🎨 Vue Components

### Available Components
- **Dashboard.vue** - Analytics dashboard
- **KanbanBoard.vue** - Drag-and-drop task board
- **ProjectList.vue** - Projects table with search
- **ProjectForm.vue** - Create/edit projects
- **Calendar.vue** - Calendar view
- **AdvancedSearch.vue** - Full-text search with filters
- **CommentThread.vue** - Comments interface
- **FileUploader.vue** - Drag-and-drop file uploads
- **ExportMenu.vue** - Export dropdown
- **ThemeToggle.vue** - Dark/light mode toggle
- **ProjectTemplates.vue** - Template management
- **Analytics.vue** - Advanced analytics dashboard
- **ActivityTimeline.vue** - Activity feed component

## 📧 Email Notifications

### Automated Emails
- **Project Created** - Sent when new project is created
- **Project Updated** - Sent when project details change
- **Project Assigned** - Sent when added to project team
- **Project Deadline** - Reminder 24 hours before deadline
- **Task Created** - Sent to project members
- **Task Assigned** - Sent to assigned user
- **Task Completed** - Sent when task is marked done
- **Task Overdue** - Sent for overdue tasks (daily check)
- **Task Due Soon** - Sent 24 hours before deadline

### Email Configuration
Development emails open in browser via Letter Opener.
Production emails configured via SMTP (ActionMailer).

## 🚀 Deployment

### Environment Variables
```bash
DATABASE_URL=postgresql://...
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=...
SMTP_ADDRESS=smtp.gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Production Checklist
- [ ] Configure PostgreSQL database
- [ ] Set up Redis for Sidekiq and Action Cable
- [ ] Configure SMTP for emails
- [ ] Set up SSL/TLS certificates
- [ ] Configure Nginx for WebSocket support
- [ ] Set environment variables
- [ ] Precompile assets: `rails assets:precompile`
- [ ] Run migrations: `rails db:migrate`
- [ ] Start Sidekiq workers
- [ ] Configure log rotation
- [ ] Set up monitoring (New Relic, Datadog, etc.)

## 🎯 Performance Features

- **Eager Loading** - Optimized database queries with includes
- **Background Jobs** - Async processing with Sidekiq
- **Pagination** - Kaminari for large datasets
- **Asset Optimization** - esbuild for fast builds
- **CSS Minification** - SCSS compilation with minification
- **Database Indexes** - Optimized for common queries
- **Full-text Search** - PostgreSQL ILIKE queries
- **Caching** - Fragment and query caching ready

## 🧪 Testing

- **RSpec** - Unit and integration tests
- **FactoryBot** - Test data generation
- **Faker** - Realistic fake data
- **Capybara** - End-to-end testing
- **Coverage** - SimpleCov for code coverage

## 📝 License

This project is available as open source under the terms of the MIT License.

## 🙌 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Additional Documentation

- [WebSocket Setup Guide](WEBSOCKET_SETUP.md)
- [Real-time Updates Summary](REAL_TIME_UPDATES_SUMMARY.md)

---

**Built with ❤️ using Ruby on Rails 7.2 and Vue.js 3**

*From basic CRUD to enterprise-grade project management in one upgrade cycle!*
