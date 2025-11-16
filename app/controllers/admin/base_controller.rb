# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  layout 'application'   # vue admin dédiée si tu en as une

  # droits, vérifications, etc. communs à tous les controllers admin
end