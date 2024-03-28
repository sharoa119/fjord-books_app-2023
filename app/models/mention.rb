# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :mentioning_report, class_name: 'Report', inverse_of: :mentioning_relationships
  belongs_to :mentioned_report, class_name: 'Report', inverse_of: :mentioned_relationships

  validates :mentioning_report_id, presence: true
  validates :mentioned_report_id, presence: true, uniqueness: { scope: :mentioning_report_id }
end
