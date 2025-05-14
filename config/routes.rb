Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#show"

  devise_for :users, controllers: {
    registrations: "users/registrations",
    # sessions: 'users/sessions',
    # passwords: 'users/passwords'
  }

  resource :dashboard, only: [:show], controller: 'dashboard'
  resources :transactions
  resources :categories
  resources :accounts do
    member do
      post :transfer # Assuming transfer is a POST request to a member route
    end
  end
  resource :calendar, only: [:show], controller: 'calendar'
  resources :reports, only: [:index] # Or specific routes like get 'reports/expenses_by_category'

  namespace :settings do
    get "backups/show"
    get "backups/create"
    get "notification_preferences/show"
    get "notification_preferences/update"
    get "account_settings/show"
    get "account_settings/update"
    get "passwords/show"
    get "passwords/update"
    get "profiles/show"
    get "profiles/update"
    resource :profile, only: [:show, :update]
    resource :password, only: [:show, :update] # This might conflict with Devise's password routes if not handled carefully
    resource :account_setting, only: [:show, :update]
    resource :notification_preference, only: [:show, :update]
    # resources :users_management # if applicable
    resource :backup, only: [:show, :create] # for download
  end

  # resource :feedback, only: [:new, :create] # if implemented

  # Render dynamic PWA files from app/views/pwa/*
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

