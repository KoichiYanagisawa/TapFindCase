class HistoriesController < ApplicationController
  before_action :set_user

  def create
    product_name = params[:name]
    viewed_at = params[:viewed_at]
    @history = History.create_or_update(@user['PK'], product_name, viewed_at)
  end

  def set_user
    @user = User.find_by(params[:user_id])
    unless @user
      render json: { error: 'User not found.' }, status: :not_found
    end
  end
end
