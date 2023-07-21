require 'aws-sdk-s3'

class ProductsController < ApplicationController
  def index
    @products = Product.all_unique_models
    render json: @products
  end

  def detail
    @product = Product.find_by_name(params[:name])

    @bucket = Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET_NAME'])
    @product = Product.find_by_name(params[:name])

    if @product["thumbnail_urls"]
      @product["thumbnail_urls"] = @product["thumbnail_urls"].map do |url|
        @bucket.object(url).presigned_url(:get, expires_in: 3600)
      end
    end

    if @product["image_urls"]
      @product["image_urls"] = @product["image_urls"].map do |url|
        @bucket.object(url).presigned_url(:get, expires_in: 3600)
      end
    end

    render json: {
      product: @product.as_json(only: ['name',
                                       'color',
                                       'price',
                                       'maker',
                                       'ec_site_url',
                                       'thumbnail_urls',
                                       'image_urls',
                                       'checked_at'])
    }
  end

  def modelList
    Aws.config.update({
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })

    @bucket = Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET_NAME'])

    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('model', params[:model], 'model_index', 'DETAILS', last_evaluated_key, limit)
    unless response[:products]
      return render json: { error: 'Model not found' }, status: :not_found
    end

    products = response[:products].map do |product|
      product = product.dup
      if product["thumbnail_urls"]
        product["thumbnail_url"] = @bucket.object(product["thumbnail_urls"].first).presigned_url(:get, expires_in: 3600)
      end
      product
    end
    render json: {
      products: products.as_json(only: ['PK', 'name', 'color', 'price', 'thumbnail_url']),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end

  def favoriteList
    Aws.config.update({
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })

    @bucket = Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET_NAME'])

    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('user_id', params[:user_id], 'user_id_index', 'FAVORITE', last_evaluated_key, limit)
    unless response[:products]
      return render json: { error: 'Item not found' }, status: :not_found
    end

    products = response[:products].map do |product|
      product_detail = Product.find_by_name(product["name"])

      if product_detail["thumbnail_urls"]
        product_detail["thumbnail_url"] = @bucket.object(product_detail["thumbnail_urls"].first).presigned_url(:get, expires_in: 3600)
      end
      product_detail
    end

    render json: {
      products: products.as_json(only: ['PK', 'name', 'color', 'price', 'thumbnail_url']),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end

  def historyList
    Aws.config.update({
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })

    @bucket = Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET_NAME'])

    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('user_id', params[:user_id], 'user_id_index', 'HISTORY', last_evaluated_key, limit)
    unless response[:products]
      return render json: { error: 'Item not found' }, status: :not_found
    end

    products = response[:products].map do |product|
      product_detail = Product.find_by_name(product["name"])

      if product_detail["thumbnail_urls"]
        product_detail["thumbnail_url"] = @bucket.object(product_detail["thumbnail_urls"].first).presigned_url(:get, expires_in: 3600)
      end

      viewed_at = product['viewed_at']
      product_detail.merge!('viewed_at' => viewed_at)

      product_detail
    end


    Rails.logger.info("ソート前:#products")

    sorted_products = products.sort_by { |product| -DateTime.parse(product['viewed_at']).to_i }

    Rails.logger.info(sorted_products)
  
    render json: {
      products: sorted_products.as_json(only: ['PK', 'name', 'color', 'price', 'thumbnail_url']),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end
end
