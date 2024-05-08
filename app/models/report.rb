# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  has_many :mentioning, class_name: 'Mention', foreign_key: 'mentioning_report_id', dependent: :destroy, inverse_of: :mentioning_report
  has_many :mentioning_reports, through: :mentioning, source: :mentioned_report

  has_many :mentioned, class_name: 'Mention', foreign_key: 'mentioned_report_id', dependent: :destroy, inverse_of: :mentioned_report
  has_many :mentioned_reports, through: :mentioned, source: :mentioning_report

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def build_mentions(content)
    mentioning_report_ids(content).uniq.map do |id|
      { mentioning_report_id: self.id, mentioned_report_id: id }
    end
  end

  def create_mentions(mentions)
    existing_reports = Report.where(id: mentions.map { |m| m[:mentioned_report_id] }).pluck(:id)
    mentions_to_create = mentions.reject { |m| m[:mentioned_report_id] == id || !existing_reports.include?(m[:mentioned_report_id]) }
    Mention.create(mentions_to_create) unless mentions_to_create.empty?
  end

  def save_with_mentions
    ActiveRecord::Base.transaction do
      mentioning_reports.destroy_all

      if save
        mentions_to_create = build_mentions(content)
        create_mentions(mentions_to_create)
        true
      else
        errors.add(:base, t('controllers.error.error_create', name: Report.model_name.human))
        raise ActiveRecord::Rollback
      end
    end
  end

  def update_with_mentions(report_params)
    self.attributes = report_params
    save_with_mentions
  end

  def extract_report_id_from_url(url)
    match = url.match(%r{/reports/(\d+)})
    match[1].to_i if match
  end

  def mentioning_report_ids(content)
    urls = content.scan(%r{\bhttps?://\S+\b})

    urls.map { |url| extract_report_id_from_url(url) }.uniq
  end
end
