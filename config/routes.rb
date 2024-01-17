# frozen_string_literal: true

Rails.application.routes.draw do
  resources :reports do
    resources :comments, module: :reports
  end

  resources :books do
    resources :comments, module: :books
  end

  resources :comments, only: [:destroy]

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  devise_for :users
  root to: 'books#index'
  resources :books
  resources :users, only: %i[index show]
end
