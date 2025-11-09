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

        if current_user.valid_password?(admin_password)
            ActiveRecord::Base.transaction do
            # ✅ Vérifie si le paiement a déjà été traité
            if @subscription.status == "payé"
                Rails.logger.info "⚠️ Paiement déjà traité pour la souscription #{@subscription.id}"
                redirect_to dashboard_souscription_list_path and return
            end
            
            @subscription.update!(
                status: "payé",
                paid_at: Time.current,
                payment_method: current_user.nom_complet
            )

            user = @subscription.user
            user.generate_referral_code if user.referral_code.blank?

            # 🔹 Étape 1 : Trouver le bon parrain avant d’activer le compte
            parrain_actuel = user.parrain
            if parrain_actuel.nil? || !parrain_actuel.parrain_disponible?(3)
                parrain_initial = parrain_actuel || User.racine_parrain
                nouveau_parrain = parrain_initial.premier_parrain_disponible(3)
                user.update(parrain: nouveau_parrain) if nouveau_parrain
            end

            # 🔹 Éviter une boucle : ne jamais être son propre parrain
            user.update(parrain: nil) if user.parrain_id == user.id

            # 🔹 Étape 2 : Activer le compte une fois le parrain fixé
            user.update(compte_status: true, vip_status: "open")

            # 🔹 Étape 3 : Distribuer les gains
            distribuer_gains(user)
            end

            flash[:success] = "✅ Validation manuelle effectuée avec succès."
        else
            flash[:error] = "❌ Mot de passe administrateur incorrect."
        end

        redirect_to dashboard_souscription_list_path
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