class ProductsController < ApplicationController
  def index
    @products = Product.select(:model).distinct
    render json: @products.as_json(only: [:model])
  end

  def show
    @products = Product.where(model: params[:model])
    render json: @products.as_json(only: [:id, :name, :price])
  end

  def detail
    @product = Product.find(params[:id])
    render json: @product.as_json(only: [:id, :name, :maker, :url, :price, :model, :url_image])
  end
end
