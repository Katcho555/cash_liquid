module Admin
  class SpinSettingsController < ApplicationController
    before_action :authenticate_admin!

    def edit
      @setting = SpinSetting.instance
    end

    def update
      @setting = SpinSetting.instance
      if @setting.update(setting_params)
        redirect_to edit_admin_spin_setting_path, notice: "Paramètres mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def setting_params
      params.require(:spin_setting).permit(:enabled, :spins_per_day, :point_value_in_francs, :goal_points)
    end

    def authenticate_admin!
      redirect_to root_path, alert: "Accès admin requis" unless current_user&.admin?
    end
  end
end
