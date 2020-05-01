Rails.application.routes.draw do
  root to: "home#dashboard"

  devise_for :users
  as :user do
    get 'user/edit' => 'devise/registrations#edit',   :as => 'edit_user_registration'
    put 'user'      => 'devise/registrations#update', :as => 'user_registration'
  end

  get 'users/clear_filter'
  resources :users

  get  'profile/index'
  get  'profile/picture'
  post 'profile/picture', as: 'change_profile_picture', to: 'profile#picture_create'

  get 'audits',             as: 'audits', to: 'audits#index'
  get 'audits/clear_filter'
  get 'audits/:id',         as: 'audit',  to: 'audits#show'

  get  'settings',        as: 'settings',        to: 'settings#show'
  get  'settings/edit',   as: 'edit_settings',   to: 'settings#edit'
  post 'settings/update', as: 'update_settings', to: 'settings#update'

  get 'devices/clear_filter'
  resources :devices

  get 'device_groups/clear_filter'
  resources :device_groups

  get 'device_data_records/clear_filter'
  resources :device_data_records, only: [:index, :destroy]

  get 'alarms/clear_filter'
  resources :alarms, only: [:index, :show] do
    member do
      put 'clear'
    end
  end

  get 'background_tasks/clear_filter'
  resources :background_tasks, only: [:index, :show, :new, :create, :destroy]

  namespace :api, path: 'api' do
    resources :tasks, only: :create
  end
end
