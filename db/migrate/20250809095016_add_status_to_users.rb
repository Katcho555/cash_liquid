class AddStatusToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :compte_status, :boolean, default: false
  end
end
