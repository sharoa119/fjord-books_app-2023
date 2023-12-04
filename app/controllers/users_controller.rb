# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.order(:id).page(params[:page]).per(5)
  end

  def show
    @user = User.find(params[:id])
  end

  def detail
    @user = User.find(params[:id])
  end

  def update
    if resource.update_with_password(user_params)
      bypass_sign_in(resource, scope: resource_name)
      redirect_to after_update_path_for(resource)
    else
      # clean_up_passwords resource
      # set_minimum_password_length
      respond_with resource
    end
  end

  private

  def user_params
    params.require(resource_name).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
