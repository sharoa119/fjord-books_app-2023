# frozen_string_literal: true

class Mention < ApplicationRecord
  # mentionする側
  belongs_to :mentioning_report, class_name: 'Report', inverse_of: :mentioning_relationships
  # mentionされる側
  belongs_to :mentioned_report, class_name: 'Report', inverse_of: :mentioned_relationships

  validates :mentioning_report_id, uniqueness: { scope: :mentioned_report_id }
end
