Rails.application.routes.draw do
  get '/redirect', to: 'google_api#redirect', as: 'redirect'
  get '/callback', to: 'google_api#callback', as: 'callback'
  get '/dashboard_events', to: 'google_api#dashboard_events', as: 'dashboard'
  get '/calendars', to: 'google_api#calendars', as: 'calendars'
  get '/timeslots', to: 'google_api#timeslots'
  devise_for :users
  root to: 'pages#home'
  # get '/dashboard', to: 'pages#dashboard'
  resources :users do
    resources :events
  end
  resources :events do
    resources :slots, only: %i[index new create update]
  end
  resources :slots, only: [:destroy]
end
