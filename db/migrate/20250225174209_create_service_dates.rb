class CreateServiceDates < ActiveRecord::Migration[7.1]
  def change
    create_table :service_dates do |t|
      t.integer :kind
      t.datetime :date
      t.references :location_equipment, null: false, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end

    LocationEquipment.all.each do |location_equipment|
      create_service_date(location_equipment, :service) if location_equipment.equipment.kind.eql?("power_unit")
      create_service_date(location_equipment, :battery_change)
      create_service_date(location_equipment, :belt_change) if location_equipment.equipment.kind.eql?("power_unit")
    end
  end

  def create_service_date(location_equipment, kind)
    ServiceDate.create!(
      kind: kind,
      date: location_equipment.send("next_#{kind}") || location_equipment.send("#{kind}_interval").years.from_now,
      location_equipment: location_equipment
    )
  end
end
