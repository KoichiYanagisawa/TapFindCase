class FavoritesController < ApplicationController
  before_action :set_user

  def index
    @favorites = @user.favorites.pluck(:product_id)
    render json: { favorites: @favorites }, status: :ok
  end

  def create
    @favorite = @user.favorites.create(product_id: params[:product_id])
    render json: { id: @favorite.id }, status: :created
  end

  def destroy
    @favorite = @user.favorites.find_by(product_id: params[:product_id])
    if @favorite
      @favorite.destroy
      render json: { message: 'Successfully removed from favorites.' }, status: :ok
    else
      render json: { error: 'Not found.' }, status: :not_found
    end
  end

  def show
    @favorite = @user.favorites.find_by(product_id: params[:product_id])
    if @favorite
      render json: { is_favorited: true }, status: :ok
    else
      render json: { is_favorited: false }, status: :ok
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
  end
end
