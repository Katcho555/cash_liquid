class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :amount
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
