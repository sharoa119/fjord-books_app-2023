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

  def save_with_mentions
    ActiveRecord::Base.transaction do
      if save
        create_mentions(mentioning_report_ids(content)) if content.present?
        true
      else
        errors.add(:base, t('controllers.error.error_create', name: Report.model_name.human))
        raise ActiveRecord::Rollback
      end
    end
  end

  def update_with_mentions(params)
    ActiveRecord::Base.transaction do
      if update(params)
        save_with_mentions
      else
        errors.add(:base, t('controllers.error.error_update', name: Report.model_name.human))
        raise ActiveRecord::Rollback
      end
    end
  end

  def extract_report_id_from_url(url)
    match = url.match(%r{/reports/(\d+)})
    match[1].to_i if match
  end

  def mentioning_report_ids(content)
    return [] if content.blank?

    urls = content.scan(%r{\bhttps?://\S+\b})

    urls.map { |url| extract_report_id_from_url(url) }.uniq
  end

  private

  def create_mentions(report_ids)
    report_ids.each do |id|
      mentioning.create!(mentioned_report_id: id)
    end
  end
end
