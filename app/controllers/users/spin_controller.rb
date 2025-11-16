module Users
  class SpinController < ApplicationController
    before_action :authenticate_user!

    def create
      user = current_user
      setting = SpinSetting.instance

      unless setting.enabled
        return render json: { error: "Spin désactivé" }, status: :forbidden
      end

      unless user.can_spin?
        return render json: { error: "Reviens demain pour de nouvelle chance" }, status: :forbidden
      end

      # Tirage du résultat
      options = SpinConfiguration.active.to_a
      option = weighted_pick(options)
      use_bonus = user.spins_left <= 0 && user.bonus_spins.to_i > 0
      # Appliquer le résultat et consommer spin si nécessaire
      if option.value == "bonus"
        user.apply_spin_result!("bonus") # ajoute 1 bonus spin
      elsif option.value == "retry_tomorrow"
        user.apply_spin_result!("retry_tomorrow")

      else
        user.apply_spin_result!(option.value) # ajoute points
        user.consume_spin!(use_bonus: use_bonus)   # consomme un spin normal
      end

      # Recalculer spins restants
      spins_left = user.spins_left

      render json: {
        success: true,
        label: option.label,
        value: option.value,
        message: spin_message_for(option),
        new_points: user.points,
        bonus_spins: user.bonus_spins,
        spins_left: spins_left,
        reached_goal: user.reached_goal?,

        used_bonus: user.bonus_spins_before_last_save.to_i > user.bonus_spins.to_i
      }
    rescue => e
      Rails.logger.error("Spin error #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { error: "Erreur serveur" }, status: :internal_server_error
    end

    def redeem_reward
      user = current_user
      unless user.reached_goal?
        return render json: { error: "Objectif non atteint" }, status: :forbidden
      end

      francs = user.redeem_goal!
      render json: { success: true, francs: francs, new_balance: user.balance, points: user.points }
    rescue => e
      Rails.logger.error("Rédemption error #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { error: "Erreur serveur" }, status: :internal_server_error
    end

    private

    def weighted_pick(options)
      total = options.sum { |o| o.probability.to_f }
      return options.sample if total <= 0
      point = rand * total
      options.each do |opt|
        return opt if opt.probability.to_f >= point
        point -= opt.probability.to_f
      end
      options.last
    end

    def show
    end

    def spin_message_for(option)
      case option.value
      when /\A\d+\z/ then "Félicitations : +#{option.value} points"
      when "bonus" then "Bravo : tu as gagné 1 spin bonus"
      when "retry_tomorrow" then "Pas de chance… rien cette fois ! Réessaie !"
      else "Résultat : #{option.value}"
      end
    end
  end
end
