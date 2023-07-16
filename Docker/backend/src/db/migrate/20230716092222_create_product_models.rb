class CreateProductModels < ActiveRecord::Migration[7.0]
  def change
    create_table :product_models do |t|
      t.references :product, foreign_key: true, null: false
      t.references :model, foreign_key: true, null: false

      t.timestamps
    end
  end
end
