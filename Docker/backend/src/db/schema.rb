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

ActiveRecord::Schema[7.0].define(version: 2023_07_17_010357) do
  create_table "favorites", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "histories", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "viewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_histories_on_product_id"
    t.index ["user_id"], name: "index_histories_on_user_id"
  end

  create_table "images", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "image_url", null: false
    t.string "thumbnail_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "models", charset: "utf8mb3", force: :cascade do |t|
    t.string "model", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_models", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_id"], name: "index_product_models_on_model_id"
    t.index ["product_id"], name: "index_product_models_on_product_id"
  end

  create_table "products", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", null: false
    t.string "maker", null: false
    t.string "price", limit: 20
    t.string "ec_site_url", limit: 500, null: false
    t.timestamp "checked_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ec_site_url"], name: "index_products_on_ec_site_url", unique: true
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "cookie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cookie_id"], name: "index_users_on_cookie_id", unique: true
  end

  add_foreign_key "favorites", "products"
  add_foreign_key "favorites", "users"
  add_foreign_key "histories", "products"
  add_foreign_key "histories", "users"
  add_foreign_key "images", "products"
  add_foreign_key "product_models", "models"
  add_foreign_key "product_models", "products"
end
