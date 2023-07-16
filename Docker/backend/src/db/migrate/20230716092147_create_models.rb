class CreateModels < ActiveRecord::Migration[7.0]
  def change
    create_table :models do |t|
      t.string :model, limit: 30, null: false

      t.timestamps
    end
  end
end
