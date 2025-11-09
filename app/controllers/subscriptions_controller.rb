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
    # Calcul du montant
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')&.valeur.to_i
    @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i
    @amount = @frais_souscription * @taux_dollar

     # 🔹 Vérifier s'il existe déjà une souscription en attente
  @subscription = current_user.subscriptions.find_by(status: 'en_attente')

  unless @subscription
    @subscription = current_user.subscriptions.create(
      amount: @amount,
      status: 'en_attente',
      payment_method: 'moneroo'
    )
  else
    # Mettre à jour le montant si les paramètres ont changé
    @subscription.update(amount: @amount)
  end


    if @subscription.persisted?
      moneroo = MonerooService.new

      # Créer le paiement Moneroo
      response = moneroo.create_payment(
        amount: @subscription.amount,
        currency: 'XOF',
        email: current_user.email,
        first_name: current_user.nom || "",
        last_name: current_user.prenom || "",
        description: "Souscription premium",
        return_url: callback_subscriptions_url,
        metadata: { subscription_id: @subscription.id }
      )

      Rails.logger.info "=== MONEROO RESPONSE ==="
      Rails.logger.info response.inspect
      Rails.logger.info "========================"


      
      # Redirection vers le checkout
      checkout_url = response.dig("data", "checkout_url")
      if checkout_url.present?
        redirect_to checkout_url, allow_other_host: true
      else
        flash[:alert] = "Erreur lors de la création du paiement Moneroo : #{response}"
        redirect_to subscriptions_path
      end
    else
      flash[:alert] = @subscription.errors.full_messages.join(", ")
      redirect_to subscriptions_path
    end
  end

  # Callback Moneroo
  def callback
  payment_id = params[:paymentId] || params[:reference] || params[:id]
  payment_status = params[:paymentStatus]

  # Vérifier via l’API Moneroo pour être sûr que la transaction est bien validée
  service = MonerooService.new
  verification = service.verify_payment(payment_id)

  Rails.logger.info "=== MONEROO CALLBACK ==="
  Rails.logger.info verification.inspect
  Rails.logger.info "========================"

  # Extraire les infos principales
  api_status = verification.dig("data", "status")
  metadata = verification.dig("data", "metadata") || {}

  # Trouver la souscription liée
  @souscription = Subscription.find_by(id: metadata["subscription_id"])

  unless @souscription
    flash[:error] = "Souscription introuvable."
    redirect_to failed_subscriptions_path and return
  end

  # ✅ Vérifie si le paiement a déjà été traité
  if @souscription.status == "payé"
    Rails.logger.info "⚠️ Paiement déjà traité pour la souscription #{@souscription.id}"
    redirect_to dashboard_index_path and return
  end

  # Considère le paiement réussi si :
  # - le statut API est "success" ou
  # - le paramètre URL est "success"
  if api_status == "success" || payment_status == "success"
    @souscription.update(
      status: "payé",
      payment_method: "moneroo",
      reference: payment_id,
      paid_at: Time.current
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

    # 🔹 Éviter une boucle : ne jamais être son propre parrain
    @user.update(parrain: nil) if @user.parrain_id == @user.id

    # 🔹 Étape 2 : Activer le compte une fois le parrain fixé
    @user.update(compte_status: true, vip_status: "open")

    # 🔹 Étape 3 : Distribuer les gains
    distribuer_gains(@user)

    flash[:success] = "Souscription effectuée avec succès via Moneroo ✅"
    session.delete(:souscription_amount)
    redirect_to dashboard_index_path
  else
    @souscription.update(status: "en_attente")
    flash[:error] = "Le paiement a échoué ou a été annulé ❌"
    redirect_to failed_subscriptions_path
  end
end


  # Pages de résultat
  def success
  end

  def failed
  end


end
