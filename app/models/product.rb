class Product < ApplicationRecord
     has_one_attached :image
     has_many :subscriptions
  validates :name, presence: true
  validates :purchase_price, presence: true, numericality: { greater_than: 0 }
  validates :daily_revenue, presence: true, numericality: { greater_than: 0 }
  validates :total_gain, presence: true, numericality: { greater_than: 0 }
  validates :contract_days, presence: true, numericality: { greater_than: 0 }
end
