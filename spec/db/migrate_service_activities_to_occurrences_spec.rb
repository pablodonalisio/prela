require "rails_helper"
require Rails.root.join("db/migrate/20260831120000_migrate_service_activities_to_occurrences.rb")

RSpec.describe MigrateServiceActivitiesToOccurrences do
  before do
    allow_any_instance_of(LocationEquipment).to receive(:create_initial_pending_occurrences!).and_return(nil)
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
  end

  it "migrates service activities to completed occurrences and copies documents" do
    location_equipment = create(:location_equipment, equipment: create(:equipment, :power_unit))
    les = location_equipment.location_equipment_service_for(:service)
    activity = create(:activity, kind: Activity::SERVICE, date: 1.month.ago, location_equipment: location_equipment)
    activity.document.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/test.pdf")),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    expect {
      described_class.new.up
    }.to change { les.service_occurrences.completed.count }.by(1)

    occurrence = les.service_occurrences.completed.find_by!(completed_on: activity.date.to_date)
    expect(occurrence.document).to be_attached
  end

  it "reconciles pending due_on from the latest completed occurrence" do
    freeze_time
    location_equipment = create(:location_equipment, equipment: create(:equipment, :power_unit))
    les = location_equipment.location_equipment_service_for(:service)
    les.service_occurrences.destroy_all

    completed_on = 1.month.ago.to_date
    create(:service_occurrence, :completed, location_equipment_service: les, completed_on: completed_on, due_on: completed_on)
    pending = create(:service_occurrence, location_equipment_service: les, due_on: 1.week.from_now.to_date)

    described_class.new.up

    expect(pending.reload.due_on).to eq(les.advance(completed_on))
  end
end
