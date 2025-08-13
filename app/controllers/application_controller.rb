class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    def distribuer_gains(user)

        # L’utilisateur reçoit immédiatement 300 dans son solde
        user.increment!(:balance, 300)
        
        montant_par_generation = {
            1 => 300, 2 => 200, 3 => 200, 4 => 100, 5 => 100,
            6 => 100, 7 => 50, 8 => 50, 9 => 25, 10 => 25
        }

        current_parrain = user.parrain
        generation = 1

        while current_parrain && generation <= 30
            gain = if generation <= 10
            montant_par_generation[generation] || 0
            elsif generation <= 13
            2
            else
            1
            end

            current_parrain.increment!(:balance, gain)
            current_parrain = current_parrain.parrain
            generation += 1
        end
    end

    def balance_admin
         # Somme brute des souscriptions
        @total_montant = Subscription.sum(:amount).where(status: "payé")

  
        @total_commission = User.sum(:balance)


        @total_gain = @total_montant - @total_commission

    end

     protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom, :telephone])
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom, :telephone])
    end


end
