class ParametragesController < ApplicationController
   before_action :authenticate_user!
  def show
    @taux_dollar = Parametre.find_or_create_by(cle: 'taux_dollar')
    @email_admin = Parametre.find_or_create_by(cle: 'email_admin')
    @frais_souscription = Parametre.find_or_create_by(cle: 'frais_souscription')
  end

  def update
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')
    @email_admin = Parametre.find_by(cle: 'email_admin')
    @frais_souscription = Parametre.find_by(cle: 'frais_souscription')

    success = @taux_dollar.update(valeur: params[:taux_dollar]) &&
              @email_admin.update(valeur: params[:email_admin]) &&
              @frais_souscription.update(valeur: params[:frais_souscription])


    if success
      redirect_to parametrage_path, notice: "Paramètres mis à jour avec succès ✅"
    else
      flash[:alert] = "Une erreur s’est produite."
      render :show
    end
  end
end
