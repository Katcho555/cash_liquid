class SpinConfiguration < ApplicationRecord
  validates :label, :value, :probability, presence: true
  scope :active, -> { where(active: true) }
end
