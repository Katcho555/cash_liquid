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


  # Exemple pour obtenir tous les descendants récursivement
  def all_filleuls(level = nil)
    results = []
    current_level = filleuls
    i = 1
    while current_level.any? && (level.nil? || i <= level)
      results << { niveau: i, utilisateurs: current_level }
      current_level = User.where(parrain_id: current_level.pluck(:id))
      i += 1
    end
    results
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


  def premier_parrain_disponible(max_filleuls = 3)
    queue = [self]

    until queue.empty?
      current = queue.shift
      # Ne compter que les filleuls avec compte_status == true
      active_filleuls_count = current.filleuls.where(compte_status: true).count
      if active_filleuls_count < max_filleuls
        return current
      else
        queue.concat(current.filleuls)
      end
    end

    nil
  end

  def self.racine_parrain
    find_by(role: 'admin') || first
  end

  def parrain_disponible?(max_filleuls = 3)
    filleuls.where(compte_status: true).count < max_filleuls
  end

  def filleuls_par_generation(max_generation = 30)
    generations = {}
    current_generation = [self]

    (1..max_generation).each do |gen|
      next_generation = current_generation.flat_map { |user| user.filleuls }
      break if next_generation.empty?
      generations[gen] = next_generation
      current_generation = next_generation
    end

    generations
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
def filleuls_par_niveau(max_levels = 10)
  niveaux = {}
  current_level = filleuls.to_a
  niveau = 1

  while current_level.any? && niveau <= max_levels
    niveaux[niveau] = current_level
    current_level = current_level.flat_map(&:filleuls).uniq
    niveau += 1
  end

  niveaux
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
