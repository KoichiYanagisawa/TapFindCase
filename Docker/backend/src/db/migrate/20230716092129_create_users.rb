class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :cookie_id, null: false

      t.timestamps
    end
    add_index :users, :cookie_id, unique: true
  end
end
