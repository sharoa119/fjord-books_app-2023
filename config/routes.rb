Rails.application.routes.draw do
  get 'pages/index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  resources :books
  resources :users, only: %i[index show]
  root 'pages#index'
  devise_scope :user do
    get 'user/:id', to: 'users/registrations#detail'
    get 'signup', to: 'users/registrations#new'
    get 'login', to: 'users/sessions#new'
    get 'logout', to: 'users/sessions#destroy'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
