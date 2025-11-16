module Admin
  class SpinConfigurationsController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_spin_configuration, only: [:show, :edit, :update, :destroy]

    def index
      @spin_configurations = SpinConfiguration.all.order(created_at: :asc)
    end

    def new
      @spin_configuration = SpinConfiguration.new
    end

    def create
      @spin_configuration = SpinConfiguration.new(spin_configuration_params)
      if @spin_configuration.save
        redirect_to admin_spin_configurations_path, notice: "Case ajoutée"
      else
        render :new
      end
    end

    def edit; end

    def update
      if @spin_configuration.update(spin_configuration_params)
        redirect_to admin_spin_configurations_path, notice: "Mise à jour"
      else
        render :edit
      end
    end

    def destroy
      @spin_configuration.destroy
      redirect_to admin_spin_configurations_path, notice: "Supprimé"
    end



    private

    def set_spin_configuration
      @spin_configuration = SpinConfiguration.find(params[:id])
    end

    def spin_configuration_params
      params.require(:spin_configuration).permit(:label, :value, :probability, :active)
    end

    def authenticate_admin!
      redirect_to root_path, alert: "Accès admin requis" unless current_user&.admin?
    end
  end
end
