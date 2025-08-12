class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :payment_method
      t.string :reference
      t.datetime :paid_at

      t.timestamps
    end
  end
end
