class CreateBonusCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :bonus_campaigns do |t|
        t.string  :name, null: false
      t.integer :threshold, null: false
      t.integer :reward_amount, null: false
      t.string :reward_type
      t.datetime :start_at
      t.datetime :end_at
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
