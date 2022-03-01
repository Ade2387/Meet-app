Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get '/dashboard', to: 'pages#dashboard'
  resources :users do
    resources :events
  end
  resources :events do
    resources :slots, only: %i[index new create update]
  end
  resources :slots, only: [:destroy]
end
