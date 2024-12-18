Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :passwords]
  devise_scope :user do
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root to: "home#index"

  get "home/index"
  resources :clients do
    resources :locations, except: [:index, :show]
  end
  resources :location_equipments do
    resources :reports
  end
  resources :equipment_supplies
  resources :equipment
  resources :batteries, except: %i[index]
  resources :supplies, only: [:index]
  resources :users
  resources :links
end
