# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  # mentionする側
  has_many :mentioning_relationships, class_name: 'Mention', foreign_key: 'mentioning_report_id', dependent: :destroy
  # その日報が言及している日報たち（言及先）
  # has_many ：関連名, through: :中間テーブル名, sources: :取得したい関連先
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report

  # mentionされる側
  has_many :mentioned_relationships, class_name: 'Mention', foreign_key: 'mentioned_report_id', dependent: :destroy
  # その日報に言及している日報たち（言及元）
  # has_many ：関連名, through: :中間テーブル名, sources: :取得したい関連先
  has_many :mentioned_reports, through: :mentioned_relationships, source: :mentioning_report

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end
end
