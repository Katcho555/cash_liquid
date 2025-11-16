class CreateUserSpinDailies < ActiveRecord::Migration[7.0]
  def change
    create_table :user_spin_dailies do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :spins_used, default: 0, null: false
      t.date :date, null: false
      t.timestamps
    end

    add_index :user_spin_dailies, [:user_id, :date], unique: true
  end
end
