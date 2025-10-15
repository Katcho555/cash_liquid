class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :balance_admin

  def show
    @user = current_user
  end
end
