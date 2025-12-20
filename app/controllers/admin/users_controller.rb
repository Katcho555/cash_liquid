class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :set_user, only: [:show, :edit, :update, :block, :unblock]
  before_action :balance_admin

  def index
    @users = User.order(:id).page(params[:page]).per(10)

  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Profil mis à jour."
    else
      render :edit
    end
  end

  def block
    @user.update(blocked: true)
    redirect_to admin_users_path, notice: "Compte bloqué."
  end

  def unblock
    @user.update(blocked: false)
    redirect_to admin_users_path, notice: "Compte débloqué."
  end

  private

  def check_admin
    redirect_to root_path, alert: "Accès refusé" unless current_user.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:nom, :prenom, :email, :telephone, :balance, :blocked,:role, :compte_status, :phone, :country, :city, :profession)
  end
end
