class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.references :product, foreign_key: true, null: false
      t.string :image_url, null: false
      t.string :thumbnail_url, null: false

      t.timestamps
    end
  end
end
