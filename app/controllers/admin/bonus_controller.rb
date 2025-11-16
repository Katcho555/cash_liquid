# app/controllers/admin/bonus_controller.rb
class Admin::BonusController < ApplicationController
  before_action :authenticate_user!   # si tu utilises Devise
  layout 'application'                     # optionnel

  def index; end
end