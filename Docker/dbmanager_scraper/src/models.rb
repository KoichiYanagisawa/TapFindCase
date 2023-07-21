# frozen_string_literal: true

require 'aws-record'

class ModelTable
  include Aws::Record
  string_attr :name, hash_key: true

  def self.find_or_create(name:)
    model = find(name: name)
    if model.nil?
      model = new(name: name)
      model.save
    end
    model
  end
end

class ProductModelTable
  include Aws::Record
  string_attr :product_id, hash_key: true
  string_attr :model_name, range_key: true

  def self.find_or_create(product_id:, model_name:)
    product_model = find(product_id: product_id, model_name: model_name)
    if product_model.nil?
      product_model = new(product_id: product_id, model_name: model_name)
      product_model.save
    end
    product_model
  end
end

class ImageTable
  include Aws::Record
  string_attr :product_id, hash_key: true
  string_attr :image_url
  string_attr :thumbnail_url

  def self.find_or_create(product_id:)
    image = find(product_id: product_id)
    if image.nil?
      image = new(product_id: product_id)
      image.save
    end
    image
  end
end

class ProductTable
  include Aws::Record
  string_attr :id, hash_key: true
  string_attr :name
  string_attr :maker
  string_attr :price
  string_attr :ec_site_url
  epoch_time_attr :checked_at

  def self.find_or_create(id:)
    product = find(id: id)
    if product.nil?
      product = new(id: id)
      product.save
    end
    product
  end
end
