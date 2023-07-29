class HistoriesController < ApplicationController
  before_action :set_body
  before_action :set_user

  def create
    product_name = @body['name']
    viewed_at = @body['viewed_at']
    @history = History.create_or_update(@user['PK'], product_name, viewed_at)
  end

  private

  def set_body
    @body = JSON.parse(request.body.read)
  end

  def set_user
    user_id = @body['user_id']
    @user = User.find_by(user_id)
    render json: { error: 'User not found.' }, status: :not_found unless @user
  end
end
