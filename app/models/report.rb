# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  # mentionする側
  has_many :mentioning_relationships, class_name: 'Mention', foreign_key: 'mentioning_report_id', dependent: :destroy, inverse_of: :mentioning_report
  # その日報が言及している日報たち（言及先）
  # has_many ：関連名, through: :中間テーブル名, sources: :取得したい関連先
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report

  # mentionされる側
  has_many :mentioned_relationships, class_name: 'Mention', foreign_key: 'mentioned_report_id', dependent: :destroy, inverse_of: :mentioned_report
  # その日報に言及している日報たち（言及元）
  # has_many ：関連名, through: :中間テーブル名, sources: :取得したい関連先
  has_many :mentioned_reports, through: :mentioned_relationships, source: :mentioning_report

  # 日報が保存されるときに言及を検出する
  before_save :detect_mentions

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def save_or_update_with_mentions(report_params)
    ActiveRecord::Base.transaction do
      if new_record?
        save!
      else
        update!(report_params)
      end

      detect_mentions
    end
  rescue StandardError => e
    logger.error "Failed to save or update report with mentions: #{e.message}"
    raise ActiveRecord::Rollback
  end

  private

  def detect_mentions
    # 正規表現パターンを定義（http://localhost:3000/reports/123 のようなURLを抽出）
    url_pattern = %r{(http|https)://(?:localhost|127\.0\.0\.1):3000/reports/(\d+)}

    # 本文テキストからすべてのURLを抽出
    mentioned_report_ids = content.scan(url_pattern).map { |match| match[1].to_i }

    mentioned_reports = []
    mentioned_report_ids.each do |report_id|
      report = Report.find_by(id: report_id)

      unless report
        error_message = "メンション先の日報（ID: #{report_id}）が見つかりませんでした。"
        errors.add(:base, error_message)
        return false
      end

      mentioned_reports << report
    end

    true
  end
end
