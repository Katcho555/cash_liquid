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


# puts "🌱 Création des produits..."

# products = [
#   {
#     name: "Pack Starter",
#     purchase_price: 10000,
#     daily_revenue: 500,
#     total_gain: 15000,
#     contract_days: 30,
#     description: "Idéal pour débuter l’investissement sécurisé avec un petit capital.",
#     image: "starter.jpg"
#   },
#   {
#     name: "Pack Silver",
#     purchase_price: 50000,
#     daily_revenue: 3000,
#     total_gain: 90000,
#     contract_days: 30,
#     description: "Le choix parfait pour commencer à générer de vrais revenus quotidiens.",
#     image: "silver.jpg"
#   },
#   {
#     name: "Pack Gold",
#     purchase_price: 100000,
#     daily_revenue: 7000,
#     total_gain: 180000,
#     contract_days: 30,
#     description: "Un excellent pack pour booster vos gains avec un rendement plus élevé.",
#     image: "gold.jpg"
#   },
#   {
#     name: "Pack Premium",
#     purchase_price: 250000,
#     daily_revenue: 20000,
#     total_gain: 500000,
#     contract_days: 30,
#     description: "Pour les investisseurs sérieux qui souhaitent maximiser leur retour.",
#     image: "premium.jpg"
#   },
#   {
#     name: "Pack Diamond",
#     purchase_price: 500000,
#     daily_revenue: 45000,
#     total_gain: 1000000,
#     contract_days: 30,
#     description: "Le meilleur pack avec un rendement exceptionnel.",
#     image: "diamond.jpg"
#   }
# ]

# products.each do |product_data|
#   product = Product.create!(
#     name: product_data[:name],
#     purchase_price: product_data[:purchase_price],
#     daily_revenue: product_data[:daily_revenue],
#     total_gain: product_data[:total_gain],
#     contract_days: product_data[:contract_days],
#     description: product_data[:description]
#   )

#   # 📌 Ajout image via Active Storage (si tu as des images locales dans /db/seed_images)
#   begin
#     file_path = Rails.root.join("db", "seed_images", product_data[:image])
#     if File.exist?(file_path)
#       product.image.attach(io: File.open(file_path), filename: product_data[:image])
#     end
#   rescue
#     puts "⚠️ Image introuvable pour : #{product.name}"
#   end

#   puts "👉 Produit créé : #{product.name}"
# end

# puts "✅ Seed terminé avec succès !"


# # Création ou mise à jour de l'admin racine
# admin = User.find_or_create_by!(email: "admin@cashliquid.com") do |u|
#   u.nom = "Admin"
#   u.prenom = "Super"
#   u.password = "123456"
#   u.password_confirmation = "123456"
#   u.role = "admin"
#   u.compte_status = true
#   u.current_vip = "VIP1"
#   u.vip_status = "open"
# end

# puts "Admin racine créé : #{admin.email}"



# Parametre.find_or_create_by!(cle: 'prime_parrainage') do |p|
#   p.valeur = '5'
# end


# Parametre.find_or_create_by!(cle: 'taux_dollar') do |p|
#   p.valeur = '650'
# end

# Parametre.find_or_create_by!(cle: 'email_admin') do |p|
#   p.valeur = 'admin@cashliquid.com'
# end


# puts "Paramètres créés avec succès ✅"


