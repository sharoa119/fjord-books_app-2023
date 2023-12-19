# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  validates :zip_code, presence: false
  validates :address, presence: false
end
