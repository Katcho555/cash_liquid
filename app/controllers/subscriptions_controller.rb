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
        @subscription = current_user.subscriptions.create(
            amount: 3000,
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
      @user.save

      distribuer_gains(@user)

      # Activation du compte
      @user.update(compte_status: true)

      # Vérifier si le parrain actuel a de la place
      parrain_actuel = @user.parrain
      if parrain_actuel.nil? || !parrain_actuel.parrain_disponible?(3)
        parrain_initial = parrain_actuel || User.racine_parrain

        nouveau_parrain = parrain_initial.premier_parrain_disponible(3)

        if nouveau_parrain
          @user.update(parrain: nouveau_parrain)
          Rails.logger.info "Parrain réattribué à l'utilisateur #{@user.id} : parrain #{nouveau_parrain.id}"
        else
          Rails.logger.warn "Aucun parrain disponible trouvé pour l'utilisateur #{@user.id}"
          # Gérer ce cas si besoin
        end
      end

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
