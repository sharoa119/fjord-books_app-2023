# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentions = @report.mentioned_reports
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)

    if @report.save_with_mentions(mentioning_report_ids)
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      flash[:alert] = @report.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report.update_with_mentions(report_params, mentioning_report_ids)
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      flash[:alert] = @report.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy_with_mentions(mentioning_report_ids)

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  def mentioning_report_ids
    return [] if params.dig(:report, :content).blank?

    content = params[:report][:content]
    urls = content.scan(%r{\bhttps?://\S+\b})

    mentions = []

    urls.each do |url|
      report_id = extract_report_id_from_url(url)
      mentions << report_id if report_id.present?
    end

    mentions.uniq
  end

  def extract_report_id_from_url(url)
    match = url.match(%r{/reports/(\d+)})
    match[1].to_i if match
  end
end
