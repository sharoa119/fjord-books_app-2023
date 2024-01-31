# frozen_string_literal: true

class Books::CommentsController < CommentsController
  before_action :set_commentable

  def destroy
    @comment = @commentable.comments.find(params[:id])

    @comment.destroy
    redirect_back(fallback_location: book_path)
  end

  private

  def set_commentable
    @commentable = Book.find(params[:book_id])
  end
end
