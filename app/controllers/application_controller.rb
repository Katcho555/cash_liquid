class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?
    VIP_PLANS = {
        "VIP1" => {
            amount: 3_000,
            generations: { 1 => 300, 2 => 200, 3 => 200, 4 => 100, 5 => 100, 6 => 100, 7 => 50, 8 => 50 }
        },
        "VIP2" => {
            amount: 60_000,
            generations: { 9 => 6_000, 10 => 4_002, 11 => 4_002, 12 => 4_002, 13 => 1_998, 14 => 1_998 }
        },
        "VIP3" => {
            amount: 300_000,
            generations: { 15 => 30_000, 16 => 20_010, 17 => 20_010, 18 => 9_990, 19 => 9_990 }
        },
        "VIP4" => {
            amount: 625_000,
            generations: { 20 => 62_500, 21 => 41_680, 22 => 41_680, 23 => 20_812, 24 => 20_812 }
        },
        "VIP5" => {
            amount: 975_000,
            generations: { 25 => 97_500, 26 => 65_032, 27 => 65_032, 28 => 32_460, 29 => 32_460 }
        }
    }


    def distribuer_gains(user)
  # Le nouvel utilisateur reçoit sa prime d'inscription
  user.increment!(:balance, 300)

  current_vip = user.current_vip
  vip_plan = VIP_PLANS[current_vip]
  return unless vip_plan

  # On démarre avec la 1ère génération
  gain_generations = vip_plan[:generations]
  parrain = user.parrain
  generation = 1

  # Tant qu'il y a un parrain et que la génération existe
  while parrain && gain_generations[generation]
    gain = gain_generations[generation]
    parrain.increment!(:balance, gain)
    parrain = parrain.parrain
    generation += 1
  end

  # Mise à jour du compteur de génération
  user.update!(current_vip_generation_count: generation - 1)

  # Vérification de fin de VIP
  if (generation - 1) >= gain_generations.keys.max
    next_vip = next_vip_level(current_vip)
    if next_vip
      user.update!(
        current_vip: next_vip,
        vip_status: "new",
        current_vip_generation_count: 0
      )
    else
      user.update!(vip_status: "open")
    end
  else
    user.update!(vip_status: "close")
  end
end


# Cette méthode peut être ajoutée dans ApplicationController ou User
def next_vip_level(current_vip)
  vip_keys = VIP_PLANS.keys
  current_index = vip_keys.index(current_vip)
  return nil if current_index.nil? || current_index == vip_keys.size - 1

  vip_keys[current_index + 1]
end



    def balance_admin
         # Somme brute des souscriptions
        @total_montant = Subscription.where(status: "payé").sum(:amount)

  
        @total_commission = User.sum(:balance)


        @total_gain = @total_montant - @total_commission

    end

     protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom, :telephone])
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom, :telephone])
    end


end
