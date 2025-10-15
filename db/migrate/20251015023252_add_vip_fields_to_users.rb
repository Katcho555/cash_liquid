class AddVipFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :current_vip, :string, default: "VIP1", null: false
    add_column :users, :vip_status, :string, default: "new", null: false
    add_column :users, :current_vip_generation_count, :integer, default: 0, null: false
  end
end
