require "rails_helper"
require Rails.root.join("db/migrate/20260807160000_migrate_location_equipment_statuses_to_tags.rb")

RSpec.describe MigrateLocationEquipmentStatusesToTags do
  let(:migration) { described_class.new }

  it "creates tags, tags equipment, and remaps statuses" do
    prela_to_check = create(:location_equipment)
    prela_to_deliver = create(:location_equipment)
    prela_on_service = create(:location_equipment)
    inaccessible = create(:location_equipment)
    active = create(:location_equipment, status: :active)

    # Set legacy integer statuses bypassing the shrunk enum
    LocationEquipment.where(id: prela_to_check.id).update_all(status: 2)
    LocationEquipment.where(id: prela_to_deliver.id).update_all(status: 3)
    LocationEquipment.where(id: prela_on_service.id).update_all(status: 4)
    LocationEquipment.where(id: inaccessible.id).update_all(status: 5)

    ActiveRecord::Migration.suppress_messages { migration.up }

    expect(Tag.visible.pluck(:name)).to include(
      "PRELA para revisar",
      "PRELA para entregar",
      "PRELA en service",
      "Inaccesible"
    )

    expect(prela_to_check.reload).to be_out_of_service
    expect(prela_to_check.tags.map(&:name)).to include("PRELA para revisar")

    expect(prela_to_deliver.reload).to be_out_of_service
    expect(prela_to_deliver.tags.map(&:name)).to include("PRELA para entregar")

    expect(prela_on_service.reload).to be_out_of_service
    expect(prela_on_service.tags.map(&:name)).to include("PRELA en service")

    expect(inaccessible.reload).to be_active
    expect(inaccessible.tags.map(&:name)).to include("Inaccesible")

    expect(active.reload).to be_active
    expect(active.tags).to be_empty
  end

  it "reuses an existing tag with the same name" do
    existing = create(:tag, name: "Inaccesible", color: "#112233")
    location_equipment = create(:location_equipment)
    LocationEquipment.where(id: location_equipment.id).update_all(status: 5)

    ActiveRecord::Migration.suppress_messages { migration.up }

    expect(Tag.visible.where(normalized_name: "inaccesible").count).to eq(1)
    expect(location_equipment.reload.tags).to contain_exactly(existing)
    expect(location_equipment).to be_active
  end
end
