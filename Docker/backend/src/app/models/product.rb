class Product < ApplicationRecord
  has_many :product_models
  has_many :models, through: :product_models
  has_many :images
  has_many :favorites
  validates :name, :maker, :price, :ec_site_url, presence: true
end
