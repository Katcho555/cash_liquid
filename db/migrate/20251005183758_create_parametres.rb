class CreateParametres < ActiveRecord::Migration[7.0]
  def change
    create_table :parametres do |t|
      t.string :cle
      t.string :valeur

      t.timestamps
    end
  end
end
