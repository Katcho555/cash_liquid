require 'set'

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :balance_admin

  def show
    @user = current_user
  end

def arbre
  # Si l'admin consulte sans paramètre, on affiche la racine
  if current_user.admin? && params[:id].blank?
    @user = User.find_by(role: "admin") || User.first
  else
    @user = User.find(params[:id])
  end

  @tree_data = build_tree_data(@user)
end

private

def build_tree_data(user, visited = Set.new)
  return nil if user.nil? || visited.include?(user.id)

  visited.add(user.id)

  {
    id: user.id,
    nom_complet: user.nom_complet,
    email: user.email,
    balance: user.balance || 0,
    compte_status: user.compte_status,
    filleuls_count: user.filleuls.count,
    text: {
      name: "#{user.prenom} #{user.nom}",
      title: user.email,
      desc: "Solde : #{user.balance || 0} XOF"
    },
    children: user.filleuls.map { |filleul| build_tree_data(filleul, visited) }.compact
  }
end




end
