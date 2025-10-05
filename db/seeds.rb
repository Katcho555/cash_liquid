# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Création ou mise à jour de l'admin racine
admin = User.find_or_create_by!(email: "admin@cashliquid.com") do |u|
  u.nom = "Admin"
  u.prenom = "Super"
  u.password = "123456"
  u.password_confirmation = "123456"
  u.role = "admin"
  u.compte_status = true
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


