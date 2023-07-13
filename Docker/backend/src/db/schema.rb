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

ActiveRecord::Schema[7.0].define(version: 2023_07_13_011339) do
  create_table "favorites", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.index ["product_id"], name: "product_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "history", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "viewed_at", precision: nil, null: false
    t.index ["product_id"], name: "product_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "image_url", null: false
    t.string "thumbnail_url", null: false
    t.index ["product_id"], name: "product_id"
  end

  create_table "models", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "model", limit: 30, null: false
  end

  create_table "product_models", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "model_id", null: false
    t.index ["model_id"], name: "model_id"
    t.index ["product_id"], name: "product_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", null: false
    t.string "maker", null: false
    t.string "price", limit: 20, null: false
    t.string "ec_site_url", null: false
    t.timestamp "checked_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["ec_site_url"], name: "ec_site_url", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cookie_id", null: false
    t.index ["cookie_id"], name: "cookie_id", unique: true
  end

  add_foreign_key "favorites", "products", name: "favorites_ibfk_2"
  add_foreign_key "favorites", "users", name: "favorites_ibfk_1"
  add_foreign_key "history", "products", name: "history_ibfk_2"
  add_foreign_key "history", "users", name: "history_ibfk_1"
  add_foreign_key "images", "products", name: "images_ibfk_1"
  add_foreign_key "product_models", "models", name: "product_models_ibfk_2"
  add_foreign_key "product_models", "products", name: "product_models_ibfk_1"
end
