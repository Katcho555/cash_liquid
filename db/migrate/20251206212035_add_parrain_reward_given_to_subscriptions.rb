class AddParrainRewardGivenToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :parrain_reward_given, :boolean
  end
end
