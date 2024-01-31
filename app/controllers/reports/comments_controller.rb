# frozen_string_literal: true

class Reports::CommentsController < CommentsController
  before_action :set_commentable

  def destroy
    @comment = @commentable.comments.find(params[:id])

    @comment.destroy
    redirect_back(fallback_location: report_path)
  end

  private

  def set_commentable
    @commentable = Report.find(params[:report_id])
  end
end
