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

  # Reference gallery for the Tailwind + Flowbite design system, used while
  # migrating views off Bootstrap. Remove once the migration is complete.
  unless Rails.env.production?
    get "home2", to: "home2#index"
  end

  resources :agenda, only: [:index]
  resources :clients do
    resources :locations, except: [:index, :show]
    resources :contacts, except: [:index, :show]
  end
  resources :location_equipments do
    get :field_inputs, on: :collection
    get :location_inputs, on: :collection
    resources :reports do
      get :template_fields, on: :collection
    end
    resources :activities
    resources :documents
    resources :failures
    resources :comments
    resources :location_equipment_services, only: %i[new create edit update destroy]
    resources :service_occurrences, only: %i[edit update] do
      member do
        match :complete, via: %i[get post]
      end
    end
  end
  resources :equipment_supplies
  resources :equipment do
    get :field_inputs, on: :collection
  end
  resources :batteries, except: %i[index]
  resources :supplies, only: [:index]
  resources :users
  resources :signatures, except: %i[show]
  resources :links, only: [:new, :create, :edit, :update, :destroy]
  resources :equipment_kinds do
    get "add_field", on: :collection
    get "remove_field", on: :collection
  end
  resources :service_kinds, except: %i[show]
  resources :report_templates, except: [:show] do
    get "add_field", on: :collection
    get "remove_field", on: :collection
  end
  resources :tags, except: [:show]
end
