# frozen_string_literal: true

require 'active_record'
require 'yaml'
require 'mysql2'
require 'dotenv/load'
require 'erb'

db_config = YAML.safe_load(ERB.new(File.read('./config/database.yml')).result, aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

# 機種名のクラス
class Model < ActiveRecord::Base
  has_many :product_models
  has_many :products, through: :product_models
end

# 商品と機種名の中間テーブルのクラス
class ProductModel < ActiveRecord::Base
  belongs_to :product
  belongs_to :model
end

# 写真の保存先を管理するクラス
class Image < ActiveRecord::Base
  belongs_to :product
  validates :image_url, :thumbnail_url, presence: true
end

# 商品のクラス
class Product < ActiveRecord::Base
  has_many :product_models
  has_many :models, through: :product_models
  has_many :images
  validates :name, :maker, :price, :ec_site_url, presence: true
end
