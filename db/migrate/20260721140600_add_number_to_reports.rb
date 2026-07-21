class AddNumberToReports < ActiveRecord::Migration[8.0]
  def up
    add_column :reports, :number, :integer

    execute <<~SQL
      CREATE UNIQUE INDEX index_reports_on_location_equipment_year_and_number
      ON reports (location_equipment_id, (EXTRACT(YEAR FROM date)), number)
      WHERE number IS NOT NULL;
    SQL
  end

  def down
    remove_index :reports, name: "index_reports_on_location_equipment_year_and_number"
    remove_column :reports, :number
  end
end
