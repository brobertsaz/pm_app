Rails.application.routes.draw do
  devise_for :users

  # ActionCable mount
  mount ActionCable.server => '/cable'

  root 'projects#index'

  get 'dashboard', to: 'dashboard#index'
  get 'calendar', to: 'calendar#index'
  get 'analytics', to: 'analytics#index'
  get 'analytics/project_performance', to: 'analytics#project_performance'
  get 'analytics/time_reports', to: 'analytics#time_reports'
  get 'analytics/team_productivity', to: 'analytics#team_productivity'
  get 'analytics/burndown_chart', to: 'analytics#burndown_chart'

  # Export routes
  get 'exports/projects', to: 'exports#projects_csv'
  get 'exports/projects/:id', to: 'exports#project_pdf', constraints: { id: /\d+/ }
  get 'exports/tasks', to: 'exports#tasks_csv'
  get 'exports/time_entries', to: 'exports#time_entries_csv'
  get 'exports/project_report', to: 'exports#project_report_pdf'

  resources :projects do
    resources :tasks
    get 'kanban', to: 'kanban#index'
  end

  get 'kanban', to: 'kanban#index'

  namespace :api do
    namespace :v1 do
      get 'current_user', to: 'users#current'
      get 'search', to: 'search#index'
      get 'users', to: 'users#index'
      get 'tags', to: 'tags#index'
      get 'calendar/events', to: 'calendar#events'
      resources :projects do
        resources :comments
        resources :files, only: [:index, :create, :destroy] do
          member do
            get :download
          end
        end
        resources :tasks do
          resources :comments
          resources :files, only: [:index, :create, :destroy] do
            member do
              get :download
            end
          end
          resources :time_entries do
            collection do
              get :summary
            end
          end
        end
        resources :tags
        resources :activities, only: [:index]
        resources :project_members
      end
      resources :tasks
      resources :project_templates do
        collection do
          get :public
        end
        member do
          post :instantiate
        end
        collection do
          post :from_project
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
