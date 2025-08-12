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

 

  def set_default_role
    self.role ||= 'utilisateur'
  end


  def admin?
    role == 'admin'
  end

  def utilisateur?
    role == 'utilisateur'
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


  


   private

  def generate_referral_code
    self.referral_code ||= loop do
      code = SecureRandom.hex(4)
      break code unless User.exists?(referral_code: code)
    end
  end


end
