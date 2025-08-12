class ApplicationMailer < ActionMailer::Base
  default from: "info@cashliquid.com"
  layout "mailer"

  def demande_retrait(retrait)
    @retrait = retrait
    @user = retrait.user
    mail(
      to: "hadilouidrissou@gmail.com",
      subject: "Nouvelle demande de retrait"
    )
  end

end
