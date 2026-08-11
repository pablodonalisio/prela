class SeedLocationEquipmentBaselineVersions < ActiveRecord::Migration[8.0]
  BASELINE_WHODUNNIT = "baseline"

  def up
    cutoff = LocationEquipment::FAILURE_METRICS_START_DATE.beginning_of_day

    say_with_time "Seeding baseline PaperTrail versions for location_equipments" do
      LocationEquipment.find_each do |location_equipment|
        next if PaperTrail::Version.exists?(
          item_type: "LocationEquipment",
          item_id: location_equipment.id,
          whodunnit: BASELINE_WHODUNNIT
        )

        PaperTrail::Version.create!(
          item_type: "LocationEquipment",
          item_id: location_equipment.id,
          event: "update",
          whodunnit: BASELINE_WHODUNNIT,
          created_at: cutoff,
          object: nil,
          object_changes: PaperTrail.serializer.dump(
            "status" => [nil, location_equipment.status]
          )
        )
      end
    end
  end

  def down
    PaperTrail::Version.where(
      item_type: "LocationEquipment",
      whodunnit: BASELINE_WHODUNNIT
    ).delete_all
  end
end
