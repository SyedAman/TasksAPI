Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :tasks do
      member do
        post 'assign'
        put 'progress'
      end
      collection do
        get 'overdue'
        get 'status/:status', to: 'tasks#by_status'
        get 'completed'
        get 'statistics'
      end
    end
    resources :users do
      resources :tasks, only: [:index]
    end
  end
end
