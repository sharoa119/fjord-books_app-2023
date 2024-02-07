# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]
  before_action :authorize_user, only: %i[edit update destroy]

  # GET /reports or /reports.json
  def index
    @reports = Report.order(created_at: 'DESC').includes(:user).all.page(params[:page])
  end

  # GET /reports/1 or /reports/1.json
  def show
    @commentable = @report
    @comments = @commentable.comments

    @comment = Comment.new
  end

  # GET /reports/new
  def new
    @report = current_user.reports.build
  end

  # GET /reports/1/edit
  def edit; end

  # POST /reports or /reports.json
  def create
    @report = current_user.reports.build(report_params)

    if @report.save
      redirect_to report_url(@report), notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      render :new
    end
  end

  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    if @report.update(report_params)
      redirect_to report_url(@report), notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      render :edit
    end
  end

  # DELETE /reports/1 or /reports/1.json
  def destroy
    @report.destroy
    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def authorize_user
    return if current_user == @report.user

    redirect_to root_path, alert: t('controllers.common.alert')
  end

  # Only allow a list of trusted parameters through.
  def report_params
    params.require(:report).permit(:title, :content).merge(user_id: current_user.id)
  end
end
