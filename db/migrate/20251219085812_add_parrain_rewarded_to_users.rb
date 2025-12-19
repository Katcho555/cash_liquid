class AddParrainRewardedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :parrain_rewarded, :boolean
  end
end
