Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup", to: "signups#create"
      post "login", to: "sessions#create"

      post "clients/register", to: "client_registrations#create"
      post "clients/login", to: "client_sessions#create"

      resources :products, only: %i[index show create]
      resources :clients, only: %i[index show create update]
      resources :orders, only: %i[index create]

      get "my/orders", to: "my_orders#index"

      namespace :marketplace do
        resources :products, only: %i[index]
      end
    end
  end
end
