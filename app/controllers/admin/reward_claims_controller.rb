class Admin::RewardClaimsController < ApplicationController
  before_action :authenticate_user!  # Si tu utilises devise admin, sinon enlève

  def index
    @claims = RewardClaim.includes(:user).order(claimed_at: :desc)
  end
end
