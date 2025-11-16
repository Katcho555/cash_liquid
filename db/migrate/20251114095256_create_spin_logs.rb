class CreateSpinLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :spin_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :result_label, null: false
      t.string :value
      t.string :ip_address
      t.timestamps
    end
  end
end
