class ProductsController < ApplicationController
  def index
    @products = Model.select(:model).distinct
    render json: @products.as_json(only: [:model])
  end

  def modelList
    page = params[:page] || 1
    limit = params[:limit] || 20

    model = Model.find_by(model: params[:model])
    @products = model.products.joins(:images)
                     .select('products.id',
                             'products.name',
                             'products.color',
                             'products.price',
                             'images.thumbnail_url as thumbnail_url')
                     .page(page).per(limit)

    @products.each do |product|
      product.thumbnail_url = product.thumbnail_url.gsub('/root/src', '/root/app/public')
      file_path = product.thumbnail_url.tr('[]\"', '').split(",").first
      file_path = Rails.root.join(file_path)
      encoded_image = Base64.encode64(File.read(file_path))
      product.thumbnail_url = encoded_image
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
      product.thumbnail_url = product.thumbnail_url.gsub('/root/src', '/root/app/public')
      file_path = product.thumbnail_url.tr('[]\"', '').split(",").first
      file_path = Rails.root.join(file_path)
      encoded_image = Base64.encode64(File.read(file_path))
      product.thumbnail_url = encoded_image
    end
    render json: @products.as_json(only: [:id, :name, :color, :price, :thumbnail_url])
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

    valid_products = []

    @products.each do |product|
      product.thumbnail_url = product.thumbnail_url.gsub('/root/src', '/root/app/public') if product.thumbnail_url
      file_path = product.thumbnail_url&.tr('[]\"', '')&.split(",")&.first

      if file_path && File.exist?(file_path)
        file_path = Rails.root.join(file_path)
        encoded_image = Base64.encode64(File.read(file_path))
        product.thumbnail_url = encoded_image
        valid_products << product
      else
        Rails.logger.error("File not found at #{file_path}")
      end
    end
    render json: valid_products.as_json(only: [:id, :name, :color, :price, :thumbnail_url])
  end

  def detail
    @product = Product.joins(:models, :images).find(params[:id])
    image_urls = []
    thumbnail_urls = []

    @product.images.each do |image|
      # 画像URLのパスを書き換え
      image_paths = image.image_url.gsub('/root/src', '/root/app/public').tr('[]\"', '').split(",")

      # パスが配列形式で保存されている場合、それぞれの画像をエンコード
      image_paths.each do |path|
        file_path = Rails.root.join(path)
        # 画像ファイルを読み込み、Base64でエンコード
        encoded_image = Base64.encode64(File.read(file_path))
        image_urls << encoded_image
      end

      # サムネイルURLのパスを書き換え
      thumbnail_paths = image.thumbnail_url.gsub('/root/src', '/root/app/public').tr('[]\"', '').split(",")

      # パスが配列形式で保存されている場合、それぞれの画像をエンコード
      thumbnail_paths.each do |path|
        file_path = Rails.root.join(path)
        # 画像ファイルを読み込み、Base64でエンコード
        encoded_thumbnail = Base64.encode64(File.read(file_path))
        thumbnail_urls << encoded_thumbnail
      end
    end

    # JSONに変換してフロントエンドに返す
    render json: {
      product: @product.as_json(only: [:id, :name, :color, :maker, :price, :ec_site_url, :checked_at]),
      images: image_urls,
      thumbnails: thumbnail_urls
    }
  end
end
