class Retrait < ApplicationRecord
   belongs_to :user

  validates :methode, :numero_retrait, :nom_percepteur, :montant, presence: true
  validate :montant_inferieur_ou_egal_solde

  # Désactive la validation user pour admin
  def skip_balance_validation!
    @skip_balance_validation = true
  end

  def user_validation?
    !@skip_balance_validation
  end

  before_create :set_statut_par_defaut
  before_save :calculer_montant_net

  private

  def calculer_montant_net
    taux_retrait = Parametre.find_by(cle: "taux_retrait")&.valeur.to_f || 10
    self.montant_net = montant - (montant * taux_retrait / 100.0)
  end

  def montant_inferieur_ou_egal_solde
    return if @skip_balance_validation # <-- ignore côté admin

    if user && montant.present? && montant > user.balance
      errors.add(:montant, "ne peut pas dépasser votre solde actuel (#{user.balance} XOF)")
    end
  end

  def set_statut_par_defaut
    self.statut ||= "En attente"
  end
end
