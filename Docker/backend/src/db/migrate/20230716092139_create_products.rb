class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, limit: 255, null: false
      t.string :color, limit: 255, null: false
      t.string :maker, limit: 255, null: false
      t.string :price, limit: 20
      t.string :ec_site_url, limit: 255, null: false
      t.timestamp :checked_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_index :products, :ec_site_url, unique: true
  end
end
