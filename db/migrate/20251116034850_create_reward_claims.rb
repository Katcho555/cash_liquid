class CreateRewardClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :reward_claims do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.datetime :claimed_at, null: false

      t.timestamps
    end
  end
end
