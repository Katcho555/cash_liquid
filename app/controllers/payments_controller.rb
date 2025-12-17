class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @payment = Payment.new
    @product = Product.find(params[:product_id]) if params[:product_id]
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.user = current_user
    @payment.status = "pending"

    if @payment.save
      redirect_to @payment.product, notice: "Paiement en attente de confirmation."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :product_id)
  end
end
