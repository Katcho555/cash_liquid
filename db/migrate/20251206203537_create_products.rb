class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :purchase_price
      t.integer :daily_revenue
      t.integer :total_gain
      t.integer :contract_days
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
