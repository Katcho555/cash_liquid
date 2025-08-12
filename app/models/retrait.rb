class Retrait < ApplicationRecord
  belongs_to :user

  validates :methode, :numero_retrait, :nom_percepteur, :montant, presence: true
  validates :montant, numericality: { greater_than: 0 }
  validate :montant_inferieur_ou_egal_solde

  before_create :set_statut_par_defaut

  private

  def montant_inferieur_ou_egal_solde
    if user && montant.present? && montant > user.balance
      errors.add(:montant, "ne peut pas dépasser votre solde actuel (#{user.balance} XOF)")
    end
  end

  def set_statut_par_defaut
    self.statut ||= "En attente"
  end
end
