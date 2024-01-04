# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  validates :avatar, content_type: { in: %i[png jpg jpeg gif], message: 'はPNG、JPG、JPEG、GIFのいずれかの形式でお願いします。' }
end
