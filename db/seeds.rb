# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Création ou mise à jour de l'admin racine
# -----------------------------------
# Test complet : 8 générations de filleuls
# -----------------------------------
# global setting
SpinSetting.first_or_create!(enabled: true, spins_per_day: 1, point_value_in_francs: 1, goal_points: 100)

# default wheel (will not duplicate if already exist)
if SpinConfiguration.count == 0
  SpinConfiguration.create!([
    { label: "+5 pts", value: "5", probability: 30, active: true },
    { label: "+10 pts", value: "10", probability: 25, active: true },
    { label: "+20 pts", value: "20", probability: 15, active: true },
    { label: "+25 pts", value: "25", probability: 5, active: true },
    { label: "1 Spin Bonus", value: "bonus", probability: 5, active: true },
    { label: "Réessayer demain", value: "retry_tomorrow", probability: 20, active: true }
  ])
end

# Création ou mise à jour de l'admin racine
admin = User.find_or_create_by!(email: "admin@cashliquid.com") do |u|
  u.nom = "Admin"
  u.prenom = "Super"
  u.password = "123456"
  u.password_confirmation = "123456"
  u.role = "admin"
  u.compte_status = true
  u.current_vip = "VIP1"
  u.vip_status = "open"
end

puts "Admin racine créé : #{admin.email}"



Parametre.find_or_create_by!(cle: 'frais_souscription') do |p|
  p.valeur = '6'
end


Parametre.find_or_create_by!(cle: 'taux_dollar') do |p|
  p.valeur = '650'
end

Parametre.find_or_create_by!(cle: 'email_admin') do |p|
  p.valeur = 'admin@cashliquid.com'
end


puts "Paramètres créés avec succès ✅"


