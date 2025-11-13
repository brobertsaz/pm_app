# PM App - Modern Project Management Application

A modern, full-stack project management application built with Ruby on Rails 7.2 and Vue.js 3.

## Overview

PM App is a comprehensive project management solution that allows users to create, manage, and track projects and tasks with a beautiful, modern interface powered by Vuetify 3.

## Tech Stack

### Backend
- **Ruby**: 3.3.6
- **Rails**: 7.2.3
- **Database**: PostgreSQL
- **Authentication**: Devise 4.9
- **Authorization**: Pundit
- **API**: RESTful JSON API

### Frontend
- **Vue.js**: 3.5.12
- **Vuetify**: 3.7.4 (Material Design)
- **Axios**: 1.7.7
- **Icons**: Material Design Icons (@mdi/font)
- **Build Tool**: esbuild

### Development Tools
- **Testing**: RSpec, FactoryBot, Faker, Capybara
- **Forms**: SimpleForm
- **Templating**: HAML
- **Pagination**: Kaminari
- **CSS**: SCSS with modern utilities

## Features

### Project Management
- ✅ Create, read, update, and delete projects
- ✅ Project status tracking (Not Started, In Progress, Completed, On Hold)
- ✅ Priority levels (Low, Medium, High)
- ✅ Due date management
- ✅ User ownership and permissions
- ✅ Progress tracking with completion percentages
- ✅ Overdue project detection

### Task Management
- ✅ Create and manage tasks within projects
- ✅ Task status tracking (To Do, In Progress, Done)
- ✅ Task priorities
- ✅ Task assignment to users
- ✅ Task ordering with positions
- ✅ Due date tracking

### User Management
- ✅ User registration and authentication
- ✅ Secure password management
- ✅ Session tracking
- ✅ User-scoped data access

### Modern UI
- ✅ Responsive Material Design interface
- ✅ Interactive Vue.js components
- ✅ Real-time search and filtering
- ✅ Data tables with sorting
- ✅ Modal dialogs for confirmations
- ✅ Status and priority badges
- ✅ Clean, modern styling

### API
- ✅ RESTful JSON API (v1)
- ✅ Authenticated endpoints
- ✅ CRUD operations for projects and tasks
- ✅ Nested resources
- ✅ Error handling and validation

## Installation

### Prerequisites
- Ruby 3.3.6
- PostgreSQL
- Node.js and npm
- Bundler

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

3. **Database setup**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

4. **Build assets**
   ```bash
   npm run build
   npm run build:css
   ```

## Development

### Running the application

Start all services using Foreman:
```bash
bundle exec foreman start -f Procfile.dev
```

This will start:
- Rails server on port 3000
- JavaScript build watcher
- CSS build watcher

Or run services individually:

**Rails server:**
```bash
bundle exec rails server
```

**JavaScript build (watch mode):**
```bash
npm run build -- --watch
```

**CSS build (watch mode):**
```bash
npm run build:css -- --watch
```

### Running tests

```bash
bundle exec rspec
```

## Database Schema

### Projects
- `id`: Primary key
- `name`: String (required)
- `description`: Text (required)
- `status`: String (Not Started, In Progress, Completed, On Hold)
- `priority`: String (Low, Medium, High)
- `due_date`: Date
- `user_id`: Foreign key to users
- `created_at`, `updated_at`: Timestamps

### Tasks
- `id`: Primary key
- `title`: String (required)
- `description`: Text
- `status`: String (To Do, In Progress, Done)
- `priority`: String (Low, Medium, High)
- `due_date`: Date
- `project_id`: Foreign key to projects (required)
- `user_id`: Foreign key to users
- `position`: Integer (for ordering)
- `created_at`, `updated_at`: Timestamps

### Users (Devise)
- `id`: Primary key
- `email`: String (required, unique)
- `encrypted_password`: String
- `reset_password_token`, `reset_password_sent_at`
- `remember_created_at`
- `sign_in_count`, `current_sign_in_at`, `last_sign_in_at`
- `current_sign_in_ip`, `last_sign_in_ip`
- `created_at`, `updated_at`: Timestamps

## API Endpoints

### Projects
- `GET /api/v1/projects` - List all projects (user-scoped)
- `GET /api/v1/projects/:id` - Get project details
- `POST /api/v1/projects` - Create new project
- `PUT/PATCH /api/v1/projects/:id` - Update project
- `DELETE /api/v1/projects/:id` - Delete project

### Tasks
- `GET /api/v1/projects/:project_id/tasks` - List project tasks
- `GET /api/v1/projects/:project_id/tasks/:id` - Get task details
- `POST /api/v1/projects/:project_id/tasks` - Create new task
- `PUT/PATCH /api/v1/projects/:project_id/tasks/:id` - Update task
- `DELETE /api/v1/projects/:project_id/tasks/:id` - Delete task

## Authorization

The app uses Pundit for authorization with the following policies:

- **ProjectPolicy**: Users can only view, edit, and delete their own projects
- **TaskPolicy**: Users can manage tasks only for projects they own
- **Scope-based access**: All queries are scoped to the current user

## Upgrade Notes

This application was recently upgraded from:
- Ruby 2.5.1 → 3.3.6
- Rails 5.2 → 7.2.3
- Vue.js 2.5 → 3.5.12
- Vuetify 1.0 → 3.7.4
- Webpacker → esbuild

The upgrade included:
- Modern asset pipeline with jsbundling-rails and cssbundling-rails
- Updated authentication with Devise 4.9
- Added Pundit for authorization
- Complete Vue 3 Composition API rewrite
- Modern Vuetify 3 components
- Enhanced database schema with new fields
- RESTful API implementation
- Comprehensive testing setup

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available as open source under the terms of the MIT License.
