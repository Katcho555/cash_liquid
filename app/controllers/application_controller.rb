class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
 def distribuer_gains(user)
    # Prime d'inscription
    #user.increment!(:balance, 600)
    
  prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_i
  user.increment!(:balance, prime)

    # 🔹 Chargement dynamique depuis la base de données
  gain_generations = GenerationCommission.order(:niveau).pluck(:niveau, :commission).to_h

    parrain = user.parrain
    generation = 1

    while parrain && generation <= 10
      gain = gain_generations[generation]
      parrain.update!(balance: (parrain.balance || 0) + gain.to_f)
      parrain = parrain.parrain
      generation += 1
    end
  end


  def balance_admin

    if user_signed_in? 
      @generations = current_user.filleuls_par_generation(2)
      @generation_count = current_user.filleuls_par_generation.count
    end
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
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom, :telephone])
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom, :telephone])
    end


end
