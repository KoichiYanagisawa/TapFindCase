class ProductsController < ApplicationController
  def index
    @products = Model.select(:model).distinct
    render json: @products.as_json(only: [:model])
  end

  def modelList
    page = params[:page] || 1
    limit = params[:limit] || 20

    model = Model.find_by(model: params[:model])
    unless model
      Rails.logger.error('Model not found')
      return render json: { error: 'Model not found' }, status: :not_found
    end

    @products = model.products.joins(:images)
                     .select('products.id',
                             'products.name',
                             'products.color',
                             'products.price',
                             'images.thumbnail_url as thumbnail_url')
                     .page(page).per(limit)

    @products.each do |product|
      thumbnail_urls = JSON.parse(product.thumbnail_url)
      if thumbnail_urls.any?
        product.thumbnail_url = generate_presigned_url(thumbnail_urls.first)
      end
    end

    render json: @products.as_json(only: [:id, :name, :color, :price, :thumbnail_url])
  end

  def favoriteList
    page = params[:page] || 1
    limit = params[:limit] || 20

    user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    @products = user.favorites.joins(:product => :images)
                    .select('products.id',
                            'products.name',
                            'products.color',
                            'products.price',
                            'images.thumbnail_url as thumbnail_url')
                    .page(page).per(limit)

    @products.each do |product|
      thumbnail_urls = JSON.parse(product.thumbnail_url)
      if thumbnail_urls.any?
        product.thumbnail_url = generate_presigned_url(thumbnail_urls.first)
      end
    end

    render json: @products.as_json(only: [:id, :name, :color, :price, :thumbnail_url])
  end

  def historyList
    page = params[:page] || 1
    limit = params[:limit] || 20

    user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    @products = user.histories.joins(:product => :images)
                    .select('products.id',
                            'products.name',
                            'products.color',
                            'products.price',
                            'images.thumbnail_url as thumbnail_url')
                    .order('histories.updated_at DESC')
                    .page(page).per(limit)

    @products.each do |product|
      thumbnail_urls = JSON.parse(product.thumbnail_url)
      if thumbnail_urls.any?
        product.thumbnail_url = generate_presigned_url(thumbnail_urls.first)
      end
    end

    render json: @products.as_json(only: [:id, :name, :color, :price, :thumbnail_url])
  end

  def detail
    @product = Product.joins(:models, :images).find(params[:id])
    image_urls = []
    thumbnail_urls = []

    @product.images.each do |image|
      image_paths = JSON.parse(image.image_url)
      image_paths.each do |path|
        presigned_image_url = generate_presigned_url(path)
        image_urls << presigned_image_url
      end

      thumbnail_paths = JSON.parse(image.thumbnail_url)
      thumbnail_paths.each do |path|
        presigned_thumbnail_url = generate_presigned_url(path)
        thumbnail_urls << presigned_thumbnail_url
      end
    end

    render json: {
      product: @product.as_json(only: [:id, :name, :color, :maker, :price, :ec_site_url, :checked_at]),
      images: image_urls,
      thumbnails: thumbnail_urls
    }
  end
end
