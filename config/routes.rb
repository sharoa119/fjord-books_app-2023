Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.map(&:to_s).join('|')}/ do
    resources :books
  end
  # Defines the root path route ("/")
  # root "articles#index"
end
