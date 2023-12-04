# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :books
  resources :users, only: %i[index show]

  devise_scope :user do
    get 'user/:id', to: 'users/registrations#detail'
    get 'signup', to: 'users/registrations#new'
    get 'login', to: 'users/sessions#new'
  end

  root 'pages#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
