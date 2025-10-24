class SubscriptionsController < ApplicationController
    before_action :authenticate_user!

  def index
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')&.valeur.to_i
    @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i
    if params[:id]
        @subscription = Subscription.find_by(id: params[:id])
    end
    @show_payment_modal = params[:show_modal] == "true"
  end

  def create
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')&.valeur.to_i
    @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i
    @amount = @frais_souscription * @taux_dollar
    @subscription = current_user.subscriptions.create(
        amount: @amount,
        status: 'en_attente',
        payment_method: 'fedapay'
    )

    if @subscription.persisted?
        # Stocke les infos nécessaires pour affichage ultérieur
        session[:souscription_amount] = @subscription.amount
        session[:souscription_id] = @subscription.id
        redirect_to subscriptions_path(show_modal: true, id: @subscription.id)

        
    else
        flash[:alert] = @subscription.errors.full_messages.join(", ")
        redirect_to souscriptions_path
    end
  end

  def process_payment
    @souscription = Subscription.find(params[:id])
    transaction = FedaPay::Transaction.retrieve(params[:'transaction-id'])

    if transaction.status == 'approved'
      @souscription.update(
        status: "payé",
        payment_method: transaction.mode,
        reference: transaction.reference,
        paid_at: transaction.approved_at
      )

      @user = @souscription.user
      @user.generate_referral_code if @user.referral_code.blank?

      # 🔹 Étape 1 : Trouver le bon parrain avant d’activer le compte
      parrain_actuel = @user.parrain
      if parrain_actuel.nil? || !parrain_actuel.parrain_disponible?(3)
        parrain_initial = parrain_actuel || User.racine_parrain
        nouveau_parrain = parrain_initial.premier_parrain_disponible(3)
        @user.update(parrain: nouveau_parrain) if nouveau_parrain
      end

      # 🔹 Étape 2 : Activer le compte une fois le parrain fixé
      @user.update(compte_status: true, vip_status: "open")

      # 🔹 Étape 3 : Distribuer les gains
      distribuer_gains(@user)

      flash[:success] = "Souscription effectuée avec succès."
      session.delete(:souscription_amount)
      redirect_to dashboard_index_path

    else
      @souscription.update(status: "en_attente")
      flash[:error] = "Le paiement a échoué ou a été annulé. Veuillez réessayer."
      redirect_to souscriptions_path
    end
  end

end
