# frozen_string_literal: true

class CommentsController < ApplicationController
  # GET /comments/new
  def new
    @comment = @commentable.comments.build
    @comment.user = current_user
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

  private

  def comment_params
    params.require(:comment).permit(:name, :content)
  end
end
