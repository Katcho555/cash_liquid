class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :balance_admin
    def index     
        @generations = current_user.filleuls_par_generation
        @generation_count = current_user.filleuls_par_generation.count
    end

    def admin 
        @generations = User.all
        if current_user.admin?
        @total_balance = User.sum(:balance)
        else
         @total_balance = current_user.balance
        end
        @total_utilisateur_nombre = User.count
        @total_utilisateur_liste = User.all

        @retrait_sum = Retrait.where(statut: "Validé").sum(:montant)
    end

    def list_utilisateur
        if current_user.admin?
            @users = User.includes(:parrain, :filleuls).order(:id)
        else
             @users = [current_user]
        end
    end

    def souscription_list
        @subscriptions = Subscription.includes(:user).order(created_at: :desc).all
    end
end