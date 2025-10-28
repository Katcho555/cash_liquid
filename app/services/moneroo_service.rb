require 'httparty'
require 'json'

class MonerooService
  include HTTParty
  base_uri 'https://api.moneroo.io'

  def initialize
    @headers = {
      "Authorization" => "Bearer #{ENV['MONEROO_SECRET_KEY']}",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  # Créer un paiement
  def create_payment(amount:, currency:, email:, first_name:, last_name:, description:, return_url:, metadata: {}, methods: [])
    body = {
      amount: amount,
      currency: currency,
      description: description,
      customer: {
        email: email,
        first_name: first_name,
        last_name: last_name
      },
      return_url: return_url,
      metadata: metadata,
      methods: methods
    }.to_json

    response = self.class.post("/v1/payments/initialize", headers: @headers, body: body)
    # Retourner le body JSON pour le controller
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      { "error" => "Invalid JSON response", "body" => response.body }
    end
  end

  # Vérifier un paiement (GET)
  def verify_payment(payment_id)
    response = self.class.get("/v1/payments/#{payment_id}", headers: @headers)
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      { "error" => "Invalid JSON response", "body" => response.body }
    end
  end
end
