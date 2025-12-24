# app/controllers/admin/subscriptions_controller.rb
class Admin::SubscriptionsController < Admin::BaseController

  # Créditer tous les dividendes dus pour tous les utilisateurs
  def credit_all_pending
  total_credits = 0

  Subscription
    .where(status: "payé")
    .where.not(product_id: nil)   # <-- filtrage important
    .find_each do |sub|
      total_credits += sub.credit_all_due_dividends!
    end

  flash[:success] = "Tous les dividendes non crédités ont été versés : #{total_credits} FCFA"
  redirect_to admin_subscriptions_path
end


  # Créditer une seule souscription via bouton
  def credit_dividend
    sub = Subscription.find(params[:id])
    amount = sub.credit_all_due_dividends!
    flash[:success] = amount > 0 ? "Dividendes crédités : #{amount} FCFA" : "Aucun dividende à créditer"
    redirect_to admin_subscriptions_path
  end

  # Affichage de toutes les souscriptions
  def index

    @subscriptions = Subscription.includes(:user, :product).where.not(product_id: nil).order(created_at: :desc)
  end

end
