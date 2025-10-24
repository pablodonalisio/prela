class CreateFailures < ActiveRecord::Migration[8.0]
  def change
    create_table :failures do |t|
      t.string :description
      t.date :date
      t.references :location_equipment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
