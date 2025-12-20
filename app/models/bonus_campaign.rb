class BonusCampaign < ApplicationRecord
  has_many :user_bonus_campaigns, dependent: :destroy

  scope :active_now, -> {
    where(active: true)
      .where("start_at IS NULL OR start_at <= ?", Time.current)
      .where("end_at IS NULL OR end_at >= ?", Time.current)
  }
end
