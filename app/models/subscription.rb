class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product, optional: true

  # Jours écoulés depuis le paiement (tranches exactes de 24h)
  def elapsed_days
    return 0 unless paid_at
    ((Time.current - paid_at) / 1.day).floor
  end

  # Jours déjà crédités
  def credited_days
    return 0 unless last_credit_at && product
    [
      ((last_credit_at - paid_at) / 1.day).floor,
      product.contract_days
    ].min
  end

  # Nombre total de jours payables
  def payable_days
    return 0 unless product
    [elapsed_days, product.contract_days].min
  end

  # Nombre de jours à rattraper
  def due_days
    [payable_days - credited_days, 0].max
  end

  # Vérifie si un dividende peut être crédité
  def dividend_due?
    return false unless product
    status == "payé" && due_days > 0
  end

  # Crédit tous les dividendes dus
  def credit_all_due_dividends!
    return 0 unless dividend_due?

    total_amount = due_days * product.daily_revenue

    ActiveRecord::Base.transaction do
      user.increment!(:balance, total_amount)
      update!(last_credit_at: paid_at + payable_days.days)
    end

    total_amount
  end

  def total_earned
    return 0 unless product
    credited_days * product.daily_revenue
  end

  def contract_day
    payable_days
  end

  def status_label
    return "En attente" if status == "en_attente"
    return "Contrat terminé" if product && credited_days >= product.contract_days
    "En cours"
  end
end
