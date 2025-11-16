class SpinLog < ApplicationRecord
  belongs_to :user
  validates :result_label, presence: true
end
