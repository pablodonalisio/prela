Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "location_equipments#index"

  get "home/index"
  resources :clients do
    resources :locations, except: [:index, :show]
  end
  resources :location_equipments
  resources :equipment_supplies
  resources :equipment
  resources :batteries, except: %i[index show]
  resources :supplies, only: [:index]
end
