class AddMontantNetToRetraits < ActiveRecord::Migration[7.0]
  def change
    add_column :retraits, :montant_net, :decimal
  end
end
