class FavoritesController < ApplicationController
  before_action :set_user

  def index
    @favorites = Favorite.find_all_by_user(user_id: @user['PK'])
    render json: { favorites: @favorites }, status: :ok
  end

  def show
    @favorite = Favorite.find_by_user_and_case(user_id: @user['PK'], case_name: params[:case_name])
    if @favorite
      render json: { is_favorited: true }, status: :ok
    else
      render json: { is_favorited: false }, status: :ok
    end
  end
  def create
    @favorite = Favorite.create(user_id: @user['PK'], product_id: params[:product_id])
    render json: { product_id: @favorite['product_id'] }, status: :created
  end

  def destroy
    @favorite = Favorite.find_by(user_id: @user['PK'], product_id: params[:product_id])
    if @favorite
      Favorite.destroy(user_id: @user['PK'], product_id: params[:product_id])
      render json: { message: 'Successfully removed from favorites.' }, status: :ok
    else
      render json: { error: 'Not found.' }, status: :not_found
    end
  end


  private

  def set_user
    @user = User.find_by(params[:user_id])
    render json: { error: 'User not found.' }, status: :not_found unless @user
  end
end
