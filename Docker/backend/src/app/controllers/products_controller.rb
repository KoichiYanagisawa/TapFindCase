require 'aws-sdk-s3'

class ProductsController < ApplicationController
  before_action :initialize_s3_client, only: %i[detail model_list favorite_list history_list]

  def initialize_s3_client
    Aws.config.update({
                        region: ENV.fetch('MY_AWS_REGION', nil),
                        credentials: Aws::Credentials.new(ENV.fetch('MY_AWS_ACCESS_KEY_ID', nil), ENV.fetch('MY_AWS_SECRET_ACCESS_KEY', nil))
                      })

    @bucket = Aws::S3::Resource.new.bucket(ENV.fetch('BACKEND_AWS_S3_BUCKET', nil))
  end

  def index
    @products = Product.all_unique_models
    render json: @products
  end

  def detail
    @product = Product.find_by_name(params[:name])
    unless @product
      render json: { error: 'Product not found' }, status: :not_found
      return
    end

    presigned_url_result = generate_presigned_url(@product, ['thumbnail_urls', 'image_urls'])

    unless presigned_url_result == true
      render json: { error: presigned_url_result }, status: :not_found
      return
    end

    render json: {
      product: @product.as_json(only: %w[name
                                         color
                                         price
                                         maker
                                         ec_site_url
                                         thumbnail_urls
                                         image_urls
                                         checked_at])
    }
  end

  def model_list
    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('model', params[:model], 'model_index', 'DETAILS', last_evaluated_key, limit)
    return render json: { error: 'Model not found' }, status: :not_found unless response[:products]

    products = generate_thumbnail_urls(response)
    render json: {
      products: products.as_json(only: %w[PK name color price thumbnail_url]),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end

  def favorite_list
    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('user_id', params[:user_id], 'user_id_index', 'FAVORITE', last_evaluated_key, limit)
    return render json: { error: 'Item not found' }, status: :not_found unless response[:products]

    products = generate_thumbnail_urls(response)

    render json: {
      products: products.as_json(only: %w[PK name color price thumbnail_url]),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end

  def history_list
    last_evaluated_key = params[:last_evaluated_key].present? ? JSON.parse(params[:last_evaluated_key]) : nil
    limit = params[:limit] || 20

    response = Product.find_by('user_id', params[:user_id], 'user_id_index', 'HISTORY', last_evaluated_key, limit)
    return render json: { error: 'Item not found' }, status: :not_found unless response[:products]

    products = generate_thumbnail_urls(response, true)
    sorted_products = products.sort_by { |product| -DateTime.parse(product['viewed_at']).to_i }

    render json: {
      products: sorted_products.as_json(only: %w[PK name color price thumbnail_url]),
      last_evaluated_key: response[:last_evaluated_key]
    }
  end

  private

  def generate_thumbnail_urls(response, viewed_at_required = false)
    response[:products].filter_map do |product|
      product = product.dup
      next unless product['thumbnail_urls']&.any? && product['thumbnail_urls'].first.present?

      begin
        product['thumbnail_url'] = @bucket.object(product['thumbnail_urls'].first).presigned_url(:get, expires_in: 3600)
      rescue ArgumentError
        next
      end

      if viewed_at_required
        product_detail = Product.find_by_name(product['name'])
        product['viewed_at'] = product_detail['viewed_at'] if product_detail&.viewed_at.present?
      end

      product
    end
  end

  def generate_presigned_url(product, url_types)
    url_types.each do |type|
      if product[type]&.any?
        product[type] = product[type].map do |url|
          @bucket.object(url).presigned_url(:get, expires_in: 3600)
        end
      else
        return 'Product image not found'
      end
    end
    true
  end
end
