# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.order(:id).page(params[:page]).per(5)
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(resource_name).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
