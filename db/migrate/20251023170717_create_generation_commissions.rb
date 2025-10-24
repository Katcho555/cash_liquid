class CreateGenerationCommissions < ActiveRecord::Migration[7.0]
  def change
    create_table :generation_commissions do |t|
      t.integer :niveau
      t.integer :commission

      t.timestamps
    end
  end
end
