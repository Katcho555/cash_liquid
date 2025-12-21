class UserBonusCampaign < ApplicationRecord
  belongs_to :user
  belongs_to :bonus_campaign
  enum status: {
    in_progress: "in_progress",
    ready_to_claim: "ready_to_claim",
    rewarded: "rewarded",
    expired: "expired"
  }

end
