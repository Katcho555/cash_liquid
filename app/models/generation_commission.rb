class GenerationCommission < ApplicationRecord
    validates :niveau, presence: true, uniqueness: true
    validates :commission, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
