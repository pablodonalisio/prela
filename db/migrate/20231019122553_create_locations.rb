class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
