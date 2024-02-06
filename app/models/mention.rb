# frozen_string_literal: true

class Mention < ApplicationRecord
  # mentionする側
  belongs_to :mentioning_report, class_name: 'Report', foreign_key: 'mentioning_report_id', inverse_of: :mentioning_relationships
  # mentionされる側
  belongs_to :mentioned_report, class_name: 'Report', foreign_key: 'mentioned_report_id', inverse_of: :mentioned_relationships
end
