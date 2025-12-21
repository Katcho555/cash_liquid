require 'set'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  ROLES = %w[admin utilisateur]
  validates :role, presence: true, inclusion: { in: ROLES }
  after_initialize :set_default_role, if: :new_record?
  has_many :subscriptions

  belongs_to :parrain, class_name: "User", optional: true
  has_many :filleuls, class_name: "User", foreign_key: :parrain_id
  has_many :retraits
  before_create :generate_referral_code
  has_many :reward_claims, dependent: :destroy

  has_many :user_bonus_campaigns, dependent: :destroy
  has_many :bonus_campaigns, through: :user_bonus_campaigns

  def reward_parrain_on_first_payment!(amount)
    return unless parrain.present?
    return if parrain_rewarded?

    prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_f || 0
    reward_amount = (amount * prime / 100).to_i

    return if reward_amount <= 0

    ActiveRecord::Base.transaction do
      parrain.increment!(:balance, reward_amount)
      update_column(:parrain_rewarded, true)
    end
  end
 

  # Nombre de filleuls actifs
  def filleuls_actifs_count
    filleuls.where(compte_status: true).count
  end

  # 🎯 Inscrire l'utilisateur aux missions disponibles
  def enroll_bonus_campaigns!
    BonusCampaign.active_now.each do |campaign|
      user_bonus_campaigns.find_or_create_by!(
        bonus_campaign: campaign
      ) do |uc|
        uc.progress = 0
        uc.status = "in_progress"
        uc.locked = false
        uc.started_at = Time.current
      end
    end
  end

  # 🔄 Mettre à jour la progression
  def update_bonus_campaigns_progress!
    user_bonus_campaigns.where(status: "in_progress").each do |uc|

      # 🔐 Si mission désactivée mais verrouillée → on continue
      next if !uc.bonus_campaign.active && !uc.locked

      progress = filleuls
      .where(compte_status: true)
      .where('users.created_at >= ?', uc.created_at)
      .count

      uc.update!(progress: progress)

      if progress >= uc.bonus_campaign.threshold
        ActiveRecord::Base.transaction do
          increment!(:balance, uc.bonus_campaign.reward_amount)
          uc.update!(status: "rewarded")
        end
      end

      # Verrouiller dès qu'il commence
      uc.update!(locked: true) if progress > 0 && !uc.locked
    end
  end

 

  def set_default_role
    self.role ||= 'utilisateur'
  end


  def admin?
    role == 'admin'
  end

  def utilisateur?
    role == 'utilisateur'
  end

  def nom_complet
    "#{nom} #{prenom}"
  end

 

  def parrainage_valide
    return unless parrain

    if parrain.all_filleuls_recursifs.map(&:id).include?(id)
      errors.add(:parrain_id, "boucle de parrainage interdite")
    end
  end


   # Exemple pour obtenir tous les descendants récursivement
  def all_filleuls
  results = []
  current_level = filleuls.to_a
  niveau = 1

  while current_level.any?
    results << { niveau: niveau, utilisateurs: current_level }
    current_level = current_level.flat_map(&:filleuls).uniq
    niveau += 1
  end

  results
end


def all_filleuls_recursifs(visited = Set.new)
  return [] if visited.include?(self)

  visited.add(self)
  descendants = filleuls + filleuls.flat_map { |f| f.all_filleuls_recursifs(visited) }
  (descendants - [self]).uniq
end


def total_filleuls_recursifs
  all_filleuls_recursifs.reject { |u| u == self }.count
end

# Retourne les filleuls par niveau : {1 => [...], 2 => [...], 3 => [...]}
def filleuls_par_niveau(max_levels = nil)
  niveaux = {}
  current_level = filleuls.to_a
  niveau = 1

  while current_level.any? && (max_levels.nil? || niveau <= max_levels)
    niveaux[niveau] = current_level
    current_level = current_level.flat_map(&:filleuls).uniq
    niveau += 1
  end

  niveaux
end


  def active_for_authentication?
    super && !blocked?
  end

  def inactive_message
    blocked? ? :blocked : super
  end

  # Somme brute actuelle
  def self.total_balance_brute
    sum(:balance)
  end

  # Total des retraits validés (montant net)
  def self.total_retraits_nets
    Retrait.where(statut: "Validé").sum(:montant_net)
  end

  # Total des retraits validés (montant brut)
  def self.total_retraits_bruts
    Retrait.where(statut: "Validé").sum(:montant)
  end

  # Montant total des frais système
  def self.total_frais_systeme
    total_retraits_bruts - total_retraits_nets
  end

  # Vision comptable ajustée pour l’admin
  def self.balance_admin_reelle
    total_balance_brute + total_frais_systeme
  end

# app/models/user.rb
has_many :spin_logs, dependent: :nullify
has_many :user_spin_dailies, dependent: :delete_all

# Record des spins du jour
def today_spin_record
  user_spin_dailies.find_or_create_by(date: Date.current)
end

# Spins restants (exclut bonus)
def spins_left
  setting = SpinSetting.instance
  return 0 unless setting.enabled
  remaining = setting.spins_per_day - today_spin_record.spins_used
  remaining < 0 ? 0 : remaining
end

# Peut faire un spin ?
def can_spin?
  return false if reached_goal?                # ← nouveau
  setting = SpinSetting.instance
  return false unless setting.enabled
  spins_left > 0 || bonus_spins.to_i > 0
end

# Consommer un spin
# use_bonus: true => consomme un spin bonus
def consume_spin!(use_bonus: false)
  transaction do
    if bonus_spins.to_i > 0 && use_bonus
      self.bonus_spins -= 1
      save!
    else
      r = today_spin_record
      r.increment!(:spins_used)
    end
  end
end

# Ajouter des points
def add_points!(amount)
  self.points = (points || 0) + amount.to_i
  save!
end

# Appliquer le résultat d'un spin
def apply_spin_result!(value)
  case value
  when /\A\d+\z/
    add_points!(value.to_i)
  when "bonus"
    # Gagne 1 spin bonus
    self.bonus_spins = (bonus_spins || 0) + 1
    save!
  when "retry_tomorrow"
    # Bloque tous les spins normaux pour aujourd'hui
    today_spin_record.update!(spins_used: SpinSetting.instance.spins_per_day)
  else
    # fallback : si numérique
    add_points!(value.to_i) rescue nil
  end
end

# Objectif atteint ?
def reached_goal?
  points.to_i >= SpinSetting.instance.goal_points.to_i
end

# Rédemption des points

def redeem_goal!
  raise "Goal not reached" unless reached_goal?
  setting = SpinSetting.instance
  francs = setting.goal_points.to_i * setting.point_value_in_francs.to_i
   transaction do
    # 🎁 Ajouter l’argent
    self.balance = (balance || 0) + francs
    self.points = 0
    self.bonus_spins = 0

    # Remettre le spin du jour à zéro
    today_spin_record.update!(spins_used: SpinSetting.instance.spins_per_day)

    save!

    # 📌 Historiser la récompense
    RewardClaim.create!(
      user: self,
      amount: francs,
      claimed_at: Time.current
    )
  end

  francs
end


  private

  def generate_referral_code
    self.referral_code ||= loop do
      code = SecureRandom.hex(4)
      break code unless User.exists?(referral_code: code)
    end
  end


end
