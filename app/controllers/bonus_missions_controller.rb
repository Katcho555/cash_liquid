# app/controllers/bonus_missions_controller.rb
class BonusMissionsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def claim_reward
    mission = current_user.user_bonus_campaigns.find(params[:id])

    if mission.ready_to_claim?
      current_user.increment!(:balance, mission.bonus_campaign.reward_amount)
      mission.update(status: "rewarded")
      flash[:notice] = "🎉 Félicitations ! Votre récompense de #{mission.bonus_campaign.reward_amount} FCFA a été ajoutée à votre solde."
    else
      flash[:alert] = "Cette récompense ne peut pas être réclamée."
    end

    redirect_to bonus_missions_path
  end
end
