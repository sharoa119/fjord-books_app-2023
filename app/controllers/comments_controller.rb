# frozen_string_literal: true

class CommentsController < ApplicationController
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

    if @comment.present? && current_user == @comment.user
      @comment.destroy
      redirect_to @commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
    else
      redirect_to @commentable, alert: t('controllers.common.alert')
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
