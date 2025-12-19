# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_12_19_085812) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "generation_commissions", force: :cascade do |t|
    t.integer "niveau"
    t.integer "commission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parametres", force: :cascade do |t|
    t.string "cle"
    t.string "valeur"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount"
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_payments_on_product_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "purchase_price"
    t.integer "daily_revenue"
    t.integer "total_gain"
    t.integer "contract_days"
    t.text "description"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "retraits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "methode"
    t.string "numero_retrait"
    t.string "nom_percepteur"
    t.decimal "montant"
    t.string "statut"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "montant_net"
    t.index ["user_id"], name: "index_retraits_on_user_id"
  end

  create_table "reward_claims", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.datetime "claimed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reward_claims_on_user_id"
  end

  create_table "spin_configurations", force: :cascade do |t|
    t.string "label", null: false
    t.string "value", null: false
    t.float "probability", default: 0.0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spin_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "result_label", null: false
    t.string "value"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_spin_logs_on_user_id"
  end

  create_table "spin_settings", force: :cascade do |t|
    t.boolean "enabled", default: true, null: false
    t.integer "spins_per_day", default: 1, null: false
    t.integer "point_value_in_francs", default: 1, null: false
    t.integer "goal_points", default: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount"
    t.string "status"
    t.string "payment_method"
    t.string "reference"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.boolean "parrain_reward_given"
    t.datetime "last_credit_at"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_spin_dailies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "spins_used", default: 0, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date"], name: "index_user_spin_dailies_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_user_spin_dailies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.integer "balance", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom"
    t.string "prenom"
    t.string "role"
    t.string "referral_code"
    t.integer "parrain_id"
    t.boolean "compte_status", default: false
    t.boolean "blocked"
    t.string "telephone"
    t.string "current_vip", default: "VIP1", null: false
    t.string "vip_status", default: "new", null: false
    t.integer "current_vip_generation_count", default: 0, null: false
    t.datetime "last_spin_at"
    t.integer "bonus_spins", default: 0, null: false
    t.integer "points", default: 0, null: false
    t.boolean "parrain_rewarded"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "payments", "products"
  add_foreign_key "payments", "users"
  add_foreign_key "retraits", "users"
  add_foreign_key "reward_claims", "users"
  add_foreign_key "spin_logs", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_spin_dailies", "users"
end
