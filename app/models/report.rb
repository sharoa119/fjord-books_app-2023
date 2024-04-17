# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  has_many :mentioning_relationships, class_name: 'Mention', foreign_key: 'mentioning_report_id', dependent: :destroy, inverse_of: :mentioning_report
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report

  has_many :mentioned_relationships, class_name: 'Mention', foreign_key: 'mentioned_report_id', dependent: :destroy, inverse_of: :mentioned_report
  has_many :mentioned_reports, through: :mentioned_relationships, source: :mentioning_report

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def save_with_mentions(report_ids)
    return unless report_ids.present? && mentioning_reports_valid?(report_ids)

    ActiveRecord::Base.transaction do
      save!
      create_mentions(report_ids)
    rescue ActiveRecord::RecordInvalid
      errors.add(:base, t('controllers.error.error_create', name: Report.model_name.human))
      raise ActiveRecord::Rollback
    end
    # if report_ids.present? && mentioning_reports_valid?(report_ids)
    #   create_mentions(report_ids)
    #   save
    # end
  end

  def update_with_mentions(params, report_ids)
    ActiveRecord::Base.transaction do
      if update(params)
        update_mentions(self, report_ids) if mentioning_reports_valid?(report_ids)
        true
      else
        errors.add(:base, t('controllers.error.error_update', name: Report.model_name.human))
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy_with_mentions(report_ids)
    delete_mentions(report_ids)
    destroy
  end

  def self.mentioning_report_ids(content)
    return [] if content.blank?

    urls = content.scan(%r{\bhttps?://\S+\b})

    urls.map { |url| extract_report_id_from_url(url) }.uniq
  end

  private

  def mentioning_reports_valid?(report_ids)
    mentioning_report_ids(report_ids).all? do |report_id|
      Report.exists?(report_id)
    end
  end

  def mentioning_report_ids(report_ids)
    report_ids.reject { |id| id == self.id }
  end

  def create_mentions(report_ids)
    report_ids.each do |id|
      mention = mentioning_relationships.build(mentioned_report_id: id)
      mention.save
    end
  end

  def delete_mentions(report_ids)
    Mention.where(mentioning_report_id: id, mentioned_report_id: report_ids).destroy_all
  end

  def update_mentions(report, report_ids)
    old_report_ids = report.mentioning_relationships.pluck(:mentioned_report_id)
    ids_to_create = report_ids - old_report_ids
    ids_to_delete = old_report_ids - report_ids

    ids_to_create = mentioning_report_ids(ids_to_create)
    ids_to_delete = mentioning_report_ids(ids_to_delete)

    create_mentions(ids_to_create)
    delete_mentions(ids_to_delete)
  end

  def extract_report_id_from_url(url)
    match = url.match(%r{/reports/(\d+)})
    match[1].to_i if match
  end
end
