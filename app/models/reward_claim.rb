class RewardClaim < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true
  validates :claimed_at, presence: true
end
