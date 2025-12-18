class ParametragesController < ApplicationController
  before_action :authenticate_user!

  def show
    @taux_dollar = Parametre.find_or_create_by(cle: 'taux_dollar')
    @email_admin = Parametre.find_or_create_by(cle: 'email_admin')
    @prime_parrainage = Parametre.find_or_create_by(cle: 'prime_parrainage')
    @taux_retrait = Parametre.find_or_create_by(cle: 'taux_retrait')
    @commissions = GenerationCommission.order(:niveau)
  end

  def update
    @taux_dollar = Parametre.find_by(cle: 'taux_dollar')
    @email_admin = Parametre.find_by(cle: 'email_admin')
    @prime_parrainage = Parametre.find_by(cle: 'prime_parrainage')
    @taux_retrait = Parametre.find_by(cle: 'taux_retrait')

    success = @taux_dollar.update(valeur: params[:taux_dollar]) &&
              @email_admin.update(valeur: params[:email_admin]) &&
              @prime_parrainage.update(valeur: params[:prime_parrainage]) &&
              @taux_retrait.update(valeur: params[:taux_retrait])

    if success
      redirect_to parametrage_path, notice: "Paramètres mis à jour avec succès ✅"
    else
      flash[:alert] = "Une erreur s’est produite."
      render :show
    end
  end

  # Créer une génération
def create_generation
  GenerationCommission.create!(niveau: params[:niveau], commission: params[:commission])
  redirect_to parametrage_path, notice: "Génération ajoutée ✅"
end

def destroy_generation
  GenerationCommission.find(params[:id]).destroy
  redirect_to parametrage_path, notice: "Génération supprimée 🗑️"
end

def edit_generation
  @generation = GenerationCommission.find(params[:id])
end

def update_generation
  @generation = GenerationCommission.find(params[:id])
  if @generation.update(niveau: params[:niveau], commission: params[:commission])
    redirect_to parametrage_path, notice: "Génération mise à jour ✅"
  else
    render :edit_generation
  end
end







end
