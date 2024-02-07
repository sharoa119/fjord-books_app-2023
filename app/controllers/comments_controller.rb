# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authorize_comment_user, only: [:destroy]
  # GET /comments/new
  def new
    @comment = @commentable.comments.build
  end

  # POST /comments or /comments.json
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      render :new
    end
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])

    @comment.destroy
    redirect_back(fallback_location: @commentable)
  end

  private

  def authorize_comment_user
    return if current_user == @comment.user

    redirect_back(fallback_location: @commentable, alert: t('controllers.common.alert'))
  end

  def comment_params
    params.require(:comment).permit(:name, :content)
  end
end
