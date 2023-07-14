class UsersController < ApplicationController
  def show
    user = User.find_or_create_by!(cookie_id: params[:uuid])
    render json: { id: user.id }
  end
end
