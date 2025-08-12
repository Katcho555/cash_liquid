class AddBlockedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :blocked, :boolean
    add_column :users, :telephone, :string
  end
end
