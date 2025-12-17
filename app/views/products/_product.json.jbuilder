json.extract! product, :id, :name, :purchase_price, :daily_revenue, :total_gain, :contract_days, :description, :image, :created_at, :updated_at
json.url product_url(product, format: :json)
