class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :location_equipment, null: false, foreign_key: true
      t.text :observations

      t.timestamps
    end
  end
end
