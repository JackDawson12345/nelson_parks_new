require "sidekiq/web"

Rails.application.routes.draw do

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => 'admin/sidekiq'
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  devise_for :users, skip: [:registrations]

  authenticated :user do
    root to: "manage/dashboard#index", as: :authenticated_root
  end

  unauthenticated :user do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  scope module: :manage do
    root to: "dashboard#index"

    get "settings", to: "settings#index", as: :manage_settings

    get "invoices", to: "invoices#index", as: :manage_invoices

    get "invoices/gas", to: "invoices#gas", as: :manage_gas_invoices
    get "invoices/electric", to: "invoices#electric", as: :manage_electric_invoices
    get "invoices/pitch-fees", to: "invoices#pitch_fees", as: :manage_pitch_fees_invoices
    get "invoices/utilities", to: "invoices#utilities", as: :manage_utilities_invoices
    get "invoices/late-payments", to: "invoices#late_payments", as: :manage_late_payments_invoices
    get "invoices/lodge-payments", to: "invoices#lodge_payments", as: :manage_lodge_payments_invoices
    get "invoices/:id", to: "invoices#show", as: :manage_invoices_show

    get "dashboard", to: "dashboard#index", as: :manage_dashboard
  end

  namespace :admin do

    resources :exports, only: [:index]
    get '/exports/clients_export', to: 'exports#clients_export', as: :clients_export
    get '/exports/meter_reading_export', to: 'exports#meter_reading_export', as: :meter_reading_export
    get '/exports/pitch_fees_export', to: 'exports#pitch_fees_export', as: :pitch_fees_export

    resources :invoices

    patch "notifications/mark_as_seen", to: "notifications#mark_as_seen"

    resources :lodge_payments
    resources :late_payments
    resources :utilities


    get "/dashboard", to: "dashboard#index", as: :dashboard
    resources :parks
    resources :meter_readings, only: [:index, :update]
    resources :pitches
    resources :clients
    resources :invoice_batches, only: [:index, :create, :destroy] do
      post :create_invoices, on: :member
    end
    resource :settings, only: [:show, :create] do
      patch "utility_rates/:id", to: "settings#update_utility_rate", as: :utility_rate
      delete "utility_rates/:id", to: "settings#destroy_utility_rate"
    end
    resources :pitch_fees, only: [:index, :create, :update, :destroy]
  end
end