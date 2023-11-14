# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :zip_code, :address, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :zip_code, :address, :bio])
  end
end
