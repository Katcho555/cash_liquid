class Admin::BonusCampaignsController < Admin::BaseController
  def index
    @campaigns = BonusCampaign.order(created_at: :desc)
  end

  def new
    @campaign = BonusCampaign.new
  end


  # PATCH /admin/bonus_campaigns/:id/activate
  def activate
    @campaign = BonusCampaign.find(params[:id])
    @campaign.update(active: true)
    redirect_to admin_bonus_campaigns_path, notice: "Mission activée ✅"
  end

  # PATCH /admin/bonus_campaigns/:id/deactivate
  def desactivate
    @campaign = BonusCampaign.find(params[:id])
    @campaign.update(active: false)

     # Supprime les missions non commencées pour tous les utilisateurs
    UserBonusCampaign.where(bonus_campaign: @campaign, locked: false).destroy_all
    
    redirect_to admin_bonus_campaigns_path, notice: "Mission désactivée ⏸"
  end

  def create
    @campaign = BonusCampaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_bonus_campaigns_path, notice: "Mission créée"
    else
      render :new
    end
  end

  def edit
    @campaign = BonusCampaign.find(params[:id])
  end

  def update
    @campaign = BonusCampaign.find(params[:id])
    @campaign.update(campaign_params)
    redirect_to admin_bonus_campaigns_path
  end

  private

  def campaign_params
    params.require(:bonus_campaign).permit(
      :name, :threshold, :reward_amount,
      :start_at, :end_at, :active, :description, 
      :reward_type)
  end
end
