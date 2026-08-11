class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :location_equipment, null: false, foreign_key: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
