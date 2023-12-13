# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show detail update]

  def index
    @users = User.order(:id).page(params[:page]).per(5)
  end

  def show; end

  def detail; end

  def update
    if @user.update_with_password(user_params)
      bypass_sign_in(@user, scope: resource_name)
      redirect_to after_update_path_for(@user)
    else
      respond_with @user
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(resource_name).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
