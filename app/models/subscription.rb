class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Jour du contrat basé sur paid_at
  def contract_day
    return 0 if paid_at.nil?
    [(Date.today - paid_at.to_date).to_i, product.contract_days].min
  end

  # Statut lisible
  def status_label
    return "En attente" if status == "en_attente"
    return "Contrat terminé" if contract_day >= product.contract_days
    "En cours"
  end

  # Peut recevoir un dividende aujourd’hui ?
  def dividend_today?
    return false unless status == "payé"
    return false if paid_at.nil?
    return false if contract_day <= 0
    return false if contract_day >= product.contract_days

    last_credit_at.nil? || last_credit_at.to_date < Date.today
  end

  # Total gagné basé sur last_credit_at
  def total_earned
    return 0 if paid_at.nil?

    paid_days = if last_credit_at
      (last_credit_at.to_date - paid_at.to_date).to_i
    else
      0
    end

    [paid_days, product.contract_days].min * product.daily_revenue
  end

  def credited_today?
    last_credit_at&.to_date == Date.today
  end
end
