# frozen_string_literal: true

class Report < ApplicationRecord
  include Commentable
  belongs_to :user

  with_options presence: true do
    validates :title
    validates :content
  end
end
