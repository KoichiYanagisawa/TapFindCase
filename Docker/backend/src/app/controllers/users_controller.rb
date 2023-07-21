class UsersController < ApplicationController
  def show
    user = User.find_or_create_by_cookie_id(params[:uuid])
    render json: { id: user['PK'] }
  end
end
