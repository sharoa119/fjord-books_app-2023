# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_user

  protected

  def configure_permitted_parameters
    keys = %i[name postal_code address self_introduction avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys:)
    devise_parameter_sanitizer.permit(:account_update, keys:)
  end

  private

  def current_user
    # @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user ||= super || User.new
  end

  def after_sign_in_path_for(_resource_or_scope)
    books_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def signed_in_root_path(_resource_or_scope)
    user_path(current_user)
  end
end
