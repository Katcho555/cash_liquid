class SpinSetting < ApplicationRecord
  # Singleton helper
  def self.instance
    first || create!(enabled: true, spins_per_day: 1, point_value_in_francs: 1, goal_points: 100)
  end
end
