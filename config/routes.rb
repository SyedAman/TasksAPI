Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :tasks do
      member do
        post 'assign'
        put 'progress'
      end
    end
    resources :users do
      resources :tasks, only: [:index]
    end
    get 'tasks/overdue', to: 'tasks#overdue'
    get 'tasks/status/:status', to: 'tasks#by_status'
    get 'tasks/completed', to: 'tasks#completed'
    get 'tasks/statistics', to: 'tasks#statistics'
  end
end
