class CreateReportTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :report_templates do |t|
      t.string :name, null: false
      t.jsonb :equipment_specifications, null: false, default: {}
      t.jsonb :location_specifications, null: false, default: {}
      t.jsonb :measurements, null: false, default: {}
      t.jsonb :room_specifications, null: false, default: {}

      t.timestamps
    end

    create_table :location_equipments_report_templates, id: false do |t|
      t.references :location_equipment, null: false, foreign_key: true
      t.references :report_template, null: false, foreign_key: true
    end

    add_index :location_equipments_report_templates,
      [:location_equipment_id, :report_template_id],
      unique: true,
      name: "index_loc_equip_report_templates_uniqueness"
  end
end
