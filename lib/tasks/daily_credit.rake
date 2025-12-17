namespace :subscriptions do
  desc "Crédit journalier des souscriptions actives"
  task credit_daily: :environment do
    puts "=== Début crédit journalier ==="

    Subscription
      .includes(:user, :product)
      .where(status: "payé")
      .find_each do |sub|

      next unless sub.dividend_today?

      user = sub.user
      amount = sub.product.daily_revenue

      user.balance += amount
      sub.update!(last_credit_at: Time.current)
      user.save!

      puts "✔ Crédit #{amount} FCFA → User ##{user.id}"
    end

    puts "=== Fin crédit journalier ==="
  end
end
