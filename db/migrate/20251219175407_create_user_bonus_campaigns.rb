class CreateUserBonusCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :user_bonus_campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bonus_campaign, null: false, foreign_key: true
      t.integer :progress, default: 0
      t.string  :status, default: "in_progress"
      t.boolean :locked, default: false

      t.timestamps
    end

    add_index :user_bonus_campaigns, [:user_id, :bonus_campaign_id], unique: true
  end
end
