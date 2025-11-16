class AddSpinFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_spin_at, :datetime
    add_column :users, :bonus_spins, :integer, default: 0, null: false
    add_column :users, :points, :integer, default: 0, null: false
  end
end
