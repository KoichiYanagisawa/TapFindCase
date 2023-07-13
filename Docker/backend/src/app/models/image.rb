class Image < ApplicationRecord
  belongs_to :product
  validates :image_url, :thumbnail_url, presence: true
end
