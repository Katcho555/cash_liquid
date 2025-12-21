class AddStartedAtToUserBonusCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :user_bonus_campaigns, :started_at, :datetime
  end
end
