# frozen_string_literal: true

class Book < ApplicationRecord
  include Commentable
  mount_uploader :picture, PictureUploader
end
