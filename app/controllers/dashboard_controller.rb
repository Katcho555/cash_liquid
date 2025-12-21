class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :balance_admin
    before_action :verify_admin, only: [:update_balance]
    before_action :credit_user_dividends, only: [:index]

    def index 

        # Crée automatiquement les missions actives pour l'utilisateur s'il n'en a pas encore
        BonusCampaign.active_now.each do |campaign|
        current_user.user_bonus_campaigns.find_or_create_by(bonus_campaign: campaign) do |ubc|
            ubc.progress = 0
            ubc.status = "in_progress"
            ubc.locked = false  # Nouvelle mission
            ubc.started_at = Time.current
        end
        end

        # Récupère les missions assignées à l'utilisateur
        @bonus_missions = current_user.user_bonus_campaigns
                                    .includes(:bonus_campaign)
                                    .where(status: ["in_progress", "ready_to_claim"])
    end

    # Appelé lorsque l'utilisateur fait un progrès, par exemple parrainage
    def progress
        user_bonus = current_user.user_bonus_campaigns.find(params[:id])
        user_bonus.increment!(:progress, params[:amount].to_i)

        # Débloquer la mission si elle était verrouillée
        user_bonus.update(locked: true) unless user_bonus.locked?

        # Vérifier si l'objectif est atteint
        if user_bonus.progress >= user_bonus.bonus_campaign.threshold
        user_bonus.update(status: "ready_to_claim")
        # Ici, tu peux également créditer la récompense sur le solde de l'utilisateur
        end

        head :ok
    end

def admin 
    @prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_f || 0
    @generations = User.all
    if current_user.utilisateur?
        @total_balance = current_user.balance
    end
    @total_utilisateur_nombre = User.count
    @total_utilisateur_liste = User.limit(15)

    @retrait_sum = Retrait.where(statut: "Validé").sum(:montant)
end

def list_utilisateur
    @prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_f || 0
    if current_user.admin?
        @users = User.includes(:parrain, :filleuls).order(:id)
        @users = @users.page(params[:page]).per(10)
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
    @subscriptions = Subscription.includes(:user).order(created_at: :desc).page(params[:page]).per(10)
end




def force_validate
    unless current_user&.role == "admin"
        redirect_to dashboard_index_path, alert: "Accès refusé 🚫"
        return
    end

    @subscription = Subscription.find(params[:id])
    admin_password = params[:admin_password]

    unless current_user.valid_password?(admin_password)
        redirect_to dashboard_souscription_list_path, alert: "❌ Mot de passe administrateur incorrect."
        return
    end

    if @subscription.status == "payé"
        redirect_to dashboard_souscription_list_path, alert: "⚠️ Paiement déjà validé."
        return
    end

    ActiveRecord::Base.transaction do
        @subscription.update!(
        status: "payé",
        paid_at: Time.current,
        payment_method: "Validation admin"
        )

        user = @subscription.user
        user.generate_referral_code if user.referral_code.blank?

        # 🔥 récompense parrain (même logique que paiement auto)
        user.reward_parrain_on_first_payment!(@subscription.amount)

        user.update!(
        compte_status: true,
        vip_status: "open"
        )
    end

    redirect_to dashboard_souscription_list_path, notice: "✅ Validation manuelle effectuée avec succès."
end


def delete_subscription
    @subscription = Subscription.find(params[:id])
    
    unless current_user&.role == "admin"
        redirect_to dashboard_index_path, alert: "Accès refusé 🚫"
        return
    end

    @subscription.destroy
    flash[:success] = "Souscription supprimée avec succès ✅"
    redirect_to dashboard_souscription_list_path
end






    private

    def verify_admin
    unless current_user.admin?
        render json: { error: "Accès refusé" }, status: :forbidden
    end
    end

end