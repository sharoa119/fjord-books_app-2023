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

  def save_with_mentions
    # トランザクションを開始
    ActiveRecord::Base.transaction do
      # 日報を保存
      save!

      # 言及データを保存
      detect_mentions
    end
  rescue StandardError => e
    # トランザクション内でのエラーが発生した場合の処理
    # エラーのハンドリングやログ出力などが必要
    logger.error "Failed to save report with mentions: #{e.message}"
    raise e
  end

  private

  def detect_mentions
    # 正規表現パターンを定義（http://localhost:3000/reports/123 のようなURLを抽出）
    url_pattern = %r{(http|https)://(?:localhost|127\.0\.0\.1):3000/reports/(\d+)}

    # 本文テキストからURLを抽出し、それぞれの日報を取得して mentioned_reports に追加する
    content.scan(url_pattern) do |match|
      report_id = match[1].to_i
      report = Report.find_by(id: report_id)
      mentioned_reports << report if report
    end
  end
end
