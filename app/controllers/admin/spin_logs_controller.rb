module Admin
  class SpinLogsController < ApplicationController
    before_action :authenticate_admin!

    def index
      @logs = SpinLog.includes(:user).order(created_at: :desc).limit(200)
    end

    def show
      @log = SpinLog.find(params[:id])
    end

    private

    def authenticate_admin!
      redirect_to root_path, alert: "Accès admin requis" unless current_user&.admin?
    end
  end
end
