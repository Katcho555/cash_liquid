class RetraitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_retrait, only: %i[show edit update destroy valider rejeter]
  before_action :balance_admin

  def index
    if current_user.admin?
      @retraits = Retrait.includes(:user).order(created_at: :desc)
    else
      @retraits = current_user.retraits.order(created_at: :desc)
    end
  end

  def valider
    unless current_user.admin?
      redirect_to retraits_path, alert: "Accès refusé."
      return
    end

    if @retrait.statut == "Validé"
       RetraitMailer.retrait_valide(@retrait).deliver_later
      redirect_to retraits_path, notice: "Ce retrait est déjà validé."
      return
    end

    user = @retrait.user

    if user.balance >= @retrait.montant
      ActiveRecord::Base.transaction do
        user.decrement!(:balance, @retrait.montant)
        @retrait.update!(statut: "Validé")
      end
      redirect_to retraits_path, notice: "Retrait validé et solde mis à jour."
    else
      redirect_to retraits_path, alert: "Solde insuffisant pour valider ce retrait."
    end
  rescue => e
    redirect_to retraits_path, alert: "Erreur lors de la validation : #{e.message}"
  end

  def rejeter
    unless current_user.admin?
      redirect_to retraits_path, alert: "Accès refusé."
      return
    end

    if @retrait.statut != "En attente"
      redirect_to retraits_path, notice: "Ce retrait est déjà traité."
      return
    end

    @retrait.update!(statut: "Rejeté")
    RetraitMailer.retrait_rejete(@retrait).deliver_later
    redirect_to retraits_path, notice: "Retrait rejeté avec succès."
  rescue => e
    redirect_to retraits_path, alert: "Erreur lors du rejet : #{e.message}"
  end


  def new
    @retrait = current_user.retraits.build
    @retrait.nom_percepteur = "#{current_user.nom} #{current_user.prenom}"
  end

  def create
    @retrait = current_user.retraits.build(retrait_params)
    if @retrait.save
       RetraitMailer.demande_retrait(@retrait).deliver_later
      redirect_to retraits_path, notice: "Votre demande de retrait a été envoyée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # autres actions (show, edit, update, destroy) si besoin

  private

  def set_retrait
    @retrait = Retrait.find(params[:id])
  end

  def retrait_params
    params.require(:retrait).permit(:methode, :numero_retrait, :nom_percepteur, :montant)
  end
end
