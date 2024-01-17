# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, only: %i[destroy]

  # GET /comments/new
  def new
    @comment = @commentable.comments.build
  end

  # POST /comments or /comments.json
  def create
    begin
      @comment = @commentable.comments.build(comment_params)
      @comment.user_id = current_user.id

      ActiveRecord::Base.transaction do
        @comment.save!
      end

      flash[:success] = 'コメントしました'
      redirect_to @commentable, notice: 'Comment was successfully created.'
    rescue => e
      Rails.logger.debug e.message
      flash[:error] = 'コメントできませんでした'
      render :new
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy
    redirect_to @commentable, notice: 'Comment was successfully destroyed.'
  end

  private

  def set_commentable
    if params[:report_id]
      @commentable = Report.find_by(id: params[:report_id])
    elsif params[:book_id]
      @commentable = Book.find_by(id: params[:book_id])
    end

    redirect_to(reports_path, alert: 'Commentable not found') unless @commentable
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content).merge(user_id: current_user.id)
  end
end
