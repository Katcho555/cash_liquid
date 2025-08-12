class RetraitMailer < ApplicationMailer

  def retrait_valide(retrait)
    @retrait = retrait
    mail(to: @retrait.user.email, subject: "Votre retrait ##{@retrait.id} a été validé")
  end

  def retrait_rejete(retrait)
    @retrait = retrait
    mail(to: @retrait.user.email, subject: "Votre retrait ##{@retrait.id} a été rejeté")
  end
end