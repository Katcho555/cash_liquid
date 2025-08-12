class CreateRetraits < ActiveRecord::Migration[7.0]
  def change
    create_table :retraits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :methode
      t.string :numero_retrait
      t.string :nom_percepteur
      t.decimal :montant
      t.string :statut

      t.timestamps
    end
  end
end
