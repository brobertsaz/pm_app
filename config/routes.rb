Rails.application.routes.draw do
  devise_for :users

  root 'projects#index'

  resources :projects do
    resources :tasks
  end

  namespace :api do
    namespace :v1 do
      resources :projects do
        resources :tasks
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
