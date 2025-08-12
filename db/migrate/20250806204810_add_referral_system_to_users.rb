class AddReferralSystemToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :referral_code, :string
    add_column :users, :parrain_id, :integer
  end
end
