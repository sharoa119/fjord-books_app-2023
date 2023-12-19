# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :books
  resources :users, only: %i[index show]

  root 'pages#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
