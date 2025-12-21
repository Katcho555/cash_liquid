class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?



  def balance_admin
    # Total des souscriptions payées (entrées d’argent)
    @total_montant = Subscription.where(status: "payé").sum(:amount)

    # Total des balances actuelles des utilisateurs (ce qu’ils ont encore)
    @total_commission = User.sum(:balance)

    # === Retraits ===
    retraits_valides = Retrait.where(statut: "Validé")
    @total_retraits_bruts = retraits_valides.sum(:montant)
    @total_retraits_nets  = retraits_valides.sum(:montant_net)

    # Total des frais système accumulés sur les retraits
    @total_frais_systeme = @total_retraits_bruts - @total_retraits_nets

    # === Gains et vision réelle ===
    # Gain total du système : argent des souscriptions - ce qui reste aux users
    @total_gain = @total_montant - @total_commission - @total_retraits_nets

    # Trésorerie réelle du système = montants encaissés + frais système
    @balance_admin_reelle = @total_commission + @total_frais_systeme
  end



     protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom, :telephone, :phone, :country, :city, :profession])
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom, :telephone, :phone, :country, :city, :profession])
    end
    private

     # Créditer tous les dividendes dus pour l'utilisateur connecté
      def credit_user_dividends
        return unless current_user

        total_credits = 0
        current_user.subscriptions.where(status: "payé").each do |sub|
          total_credits += sub.credit_all_due_dividends!
        end

        # Optionnel : stocker le total pour afficher un flash si nécessaire
        flash[:notice] = "Dividendes crédités : #{total_credits} FCFA" if total_credits > 0
      end


end
