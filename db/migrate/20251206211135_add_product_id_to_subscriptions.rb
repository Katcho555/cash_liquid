class AddProductIdToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :product_id, :integer
  end
end
