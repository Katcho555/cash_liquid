class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :balance_admin
    before_action :verify_admin, only: [:update_balance]
    def index     
        @generations = current_user.filleuls_par_generation(2)
        @generation_count = current_user.filleuls_par_generation.count
    end

    def admin 
        @generations = User.all
        if current_user.utilisateur?
         @total_balance = current_user.balance
        end
        @total_utilisateur_nombre = User.count
        @total_utilisateur_liste = User.limit(15)

        @retrait_sum = Retrait.where(statut: "Validé").sum(:montant)
    end

    def list_utilisateur
        if current_user.admin?
            @users = User.includes(:parrain, :filleuls).order(:id)
        else
             @users = [current_user]
        end
    end

    def update_balance
        user = User.find(params[:id])
        admin_password = params[:admin_password]
        new_balance = params[:balance].to_f

        # Vérifie que le mot de passe admin est correct
        if current_user.valid_password?(admin_password)
            user.update(balance: new_balance)
            render json: { success: true, balance: new_balance }
        else
            render json: { success: false, message: "Mot de passe administrateur incorrect" }, status: :unauthorized
        end
    end
    

    def souscription_list
        @subscriptions = Subscription.includes(:user).order(created_at: :desc).all
    end

    private

    def verify_admin
    unless current_user.admin?
        render json: { error: "Accès refusé" }, status: :forbidden
    end
    end

end