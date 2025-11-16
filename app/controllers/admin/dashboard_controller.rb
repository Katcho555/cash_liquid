module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_admin!

    def index
      @active = SpinConfiguration.active
      @total_spins_today = SpinLog.where("created_at >= ?", Time.current.beginning_of_day).count
    end

    private

    def authenticate_admin!
      # adapte selon ton auth (Devise Admin?)
      unless current_user&.admin?
        redirect_to root_path, alert: "Accès admin requis"
      end
    end
  end
end
