class ApplicationMailer < ActionMailer::Base
  default from: "info@cashliquid.com"
  layout "mailer"

  def demande_retrait(retrait)
    @retrait = retrait
    @user = retrait.user
    @email_admin = Parametre.find_by(cle: 'email_admin')&.valeur
    mail(
      to: @email_admin,
      subject: "Nouvelle demande de retrait"
    )
  end

end
