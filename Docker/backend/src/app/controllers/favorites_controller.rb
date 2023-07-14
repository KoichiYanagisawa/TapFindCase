class FavoritesController < ApplicationController
  before_action :set_user

  def create
    @favorite = @user.favorites.create(favorite_params)
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

  def favorite_params
    params.require(:favorite).permit(:product_id)
  end
end
