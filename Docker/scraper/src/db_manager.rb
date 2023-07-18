# frozen_string_literal: true

require 'json'
require_relative 'models'

class DbManager
  def self.store_data_to_db(item_info)
    ActiveRecord::Base.transaction do
      product = update_or_create_product(item_info)
      item_info[:models].each do |model_name|
        model = Model.find_or_create_by!(model: model_name)
        ProductModel.find_or_create_by!(product: product, model: model)
      end
      update_or_create_image(item_info, product.id)
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "store_data_to_db: #{e.message}"
  end

  def self.update_or_create_product(item_info)
    product = Product.find_or_initialize_by(name: item_info[:name], maker: item_info[:maker], color: item_info[:color])
    product.assign_attributes(
      ec_site_url: item_info[:ec_site_url],
      price: item_info[:price],
      checked_at: Time.now
    )
    product.save! if product.new_record? || product.changed?
    product
  end

  def self.update_or_create_image(item_info, product_id)
    image = Image.find_or_initialize_by(product_id: product_id)
    image.assign_attributes(
      image_url: item_info[:image_url],
      thumbnail_url: item_info[:thumbnail_url]
    )
    image.save! if image.new_record? || image.changed?
  end

  def self.delete_unchecked_data
    Product.where('checked_at < ?', 1.week.ago).destroy_all
  end
end
