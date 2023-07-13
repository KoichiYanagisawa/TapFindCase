class Model < ApplicationRecord
  has_many :product_models
  has_many :products, through: :product_models
end
