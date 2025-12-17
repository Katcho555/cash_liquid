class AddLastCreditAtToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :last_credit_at, :datetime
  end
end
