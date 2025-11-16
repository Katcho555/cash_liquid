class CreateSpinConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :spin_configurations do |t|
      t.string  :label, null: false
      t.string  :value, null: false     # numeric as string or special tokens like "bonus" or "retry_tomorrow"
      t.float   :probability, default: 0.0
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
