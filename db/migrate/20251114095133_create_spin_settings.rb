class CreateSpinSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :spin_settings do |t|
      t.boolean :enabled, default: true, null: false
      t.integer :spins_per_day, default: 1, null: false
      t.integer :point_value_in_francs, default: 1, null: false
      t.integer :goal_points, default: 100, null: false
      t.timestamps
    end
  end
end
