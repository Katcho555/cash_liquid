class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Jours écoulés depuis le paiement (tranches de 24h)
  def elapsed_days
    return 0 unless paid_at
    ((Time.current.to_date - paid_at.to_date).to_i)
  end

  # Jours déjà crédités
  def credited_days
    return 0 unless last_credit_at
    [(last_credit_at.to_date - paid_at.to_date).to_i, product.contract_days].min
  end

  # Nombre total de jours payables (respect du contrat)
  def payable_days
    [elapsed_days, product.contract_days].min
  end

  # Nombre de jours à rattraper
  def due_days
    [payable_days - credited_days, 0].max
  end

  # Vérifie si un dividende peut être crédité
  def dividend_due?
    status == "payé" && due_days > 0
  end

  # Crédit tous les dividendes dus
  def credit_all_due_dividends!
    return 0 unless dividend_due?

    total_amount = due_days * product.daily_revenue

    ActiveRecord::Base.transaction do
      user.increment!(:balance, total_amount)
      # on marque comme crédité jusqu'à aujourd'hui ou max contract_days
      update!(last_credit_at: paid_at.to_date + payable_days.days)
    end

    total_amount
  end

  def total_earned
    credited_days * product.daily_revenue
  end

  def contract_day
    payable_days
  end

  def status_label
    return "En attente" if status == "en_attente"
    return "Contrat terminé" if credited_days >= product.contract_days
    "En cours"
  end
end
