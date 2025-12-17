class SubscriptionsController < ApplicationController
    before_action :authenticate_user!

  def index
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')&.valeur.to_i
    @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i

  @taux_dollar = Parametre.find_by(cle: 'taux_dollar')&.valeur.to_i
  @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i

  if params[:product_id]
    @product = Product.find(params[:product_id])
  end

    # if params[:id]
    #     @subscription = Subscription.find_by(id: params[:id])
    # end
    @show_payment_modal = params[:show_modal] == "true"
  end

def create
  @product = Product.find(params[:product_id])
  
  # Calcul du montant = prix du produit
  @amount = @product.purchase_price

  # Vérifier s'il existe déjà une souscription en attente
  @subscription = current_user.subscriptions.find_by(status: 'en_attente')

  unless @subscription
    @subscription = current_user.subscriptions.create(
      amount: @amount,
      product_id: @product.id,   # <-- utiliser product_id ici
      status: 'en_attente',
      payment_method: 'moneroo'
    )
  else
    @subscription.update(amount: @amount, product_id: @product.id)  # <-- idem ici
  end

  if @subscription.persisted?
    moneroo = MonerooService.new

    response = moneroo.create_payment(
      amount: @subscription.amount,
      currency: 'XOF',
      email: current_user.email,
      first_name: current_user.nom || "",
      last_name: current_user.prenom || "",
      description: "Souscription pour #{@product.name}",
      return_url: callback_subscriptions_url,
      metadata: { subscription_id: @subscription.id }
    )

    checkout_url = response.dig("data", "checkout_url")
    if checkout_url.present?
      redirect_to checkout_url, allow_other_host: true
    else
      flash[:alert] = "Erreur lors de la création du paiement Moneroo : #{response}"
      redirect_to souscriptions_path(product_id: @product.id)
    end
  else
    flash[:alert] = @subscription.errors.full_messages.join(", ")
    redirect_to souscriptions_path(product_id: @product.id)
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

  # Parrainage : 5% sur le premier paiement seulement
  if @user.parrain && !@souscription.parrain_reward_given
    reward_amount = (@souscription.amount * 0.05).to_i
    @user.parrain.wallet_balance += reward_amount
    @user.parrain.save

    # Marquer que la récompense a été donnée pour cette souscription
    @souscription.update(parrain_reward_given: true)
  end

  flash[:success] = "Souscription réussie !"
  redirect_to dashboard_index_path
else
  @souscription.update(status: "en_attente")
  flash[:error] = "Le paiement a échoué."
  redirect_to failed_subscriptions_path
end



end

def credit_daily
  credits = []

  current_user.subscriptions.where(status: "payé").each do |sub|
    next unless sub.dividend_today?

    # Verser le dividende
    current_user.balance += sub.product.daily_revenue
    sub.update(last_credit_at: Time.current)

    credits << {
      id: sub.id,
      product_name: sub.product.name,
      earned: sub.product.daily_revenue
    }
  end

  current_user.save

  render json: {
    balance: current_user.balance,
    credits: credits
  }
end

def my_subscriptions
  @subscriptions = current_user.subscriptions.includes(:product)
end



  # Pages de résultat
  def success
  end

  def failed
  end


end
