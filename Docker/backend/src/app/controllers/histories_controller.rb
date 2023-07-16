class HistoriesController < ApplicationController
  before_action :set_user

  def create
    product_id = params[:product_id]
    viewed_at = params[:viewed_at]

    @history = @user.histories.find_by(product_id: product_id)

    if @history
      @history.update(viewed_at: viewed_at)
    else
      @history = @user.histories.create(product_id: product_id, viewed_at: viewed_at)
    end
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end
end
