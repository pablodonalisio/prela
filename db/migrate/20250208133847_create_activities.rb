class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :location_equipment, null: false, foreign_key: true
      t.string :description
      t.datetime :date

      t.timestamps
    end
  end
end
