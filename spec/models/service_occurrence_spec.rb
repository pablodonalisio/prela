require "rails_helper"

RSpec.describe ServiceOccurrence, type: :model do
  before do
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
    allow_any_instance_of(LocationEquipment).to receive(:create_initial_pending_occurrences!).and_return(nil)
  end

  it "is valid with required attributes" do
    expect(build(:service_occurrence)).to be_valid
  end

  it "is not valid without a due_on date" do
    expect(build(:service_occurrence, due_on: nil)).not_to be_valid
  end

  it "allows only one pending occurrence per location equipment service" do
    les = create(:location_equipment_service)
    create(:service_occurrence, location_equipment_service: les)

    duplicate = build(:service_occurrence, location_equipment_service: les)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:status]).to be_present
  end

  describe ".overdue" do
    it "includes pending occurrences with a past due_on date" do
      overdue = create(:service_occurrence, :overdue)
      create(:service_occurrence, :due_soon)

      expect(described_class.overdue).to contain_exactly(overdue)
    end
  end

  describe ".due_soon" do
    it "includes pending occurrences due within three months but not past due" do
      create(:service_occurrence, :overdue)
      due_soon = create(:service_occurrence, :due_soon)

      expect(described_class.due_soon).to contain_exactly(due_soon)
    end
  end

  describe ".due_for_attention" do
    it "includes overdue and due soon pending occurrences" do
      overdue = create(:service_occurrence, :overdue)
      due_soon = create(:service_occurrence, :due_soon)
      create(:service_occurrence, due_on: 4.months.from_now.to_date)

      expect(described_class.due_for_attention).to contain_exactly(overdue, due_soon)
    end
  end

  describe "#overdue?" do
    it "is true when pending and past due" do
      expect(build(:service_occurrence, :overdue)).to be_overdue
    end

    it "is false when due soon" do
      expect(build(:service_occurrence, :due_soon)).not_to be_overdue
    end
  end

  describe "#due_soon?" do
    it "is true when pending and within the warning window" do
      expect(build(:service_occurrence, :due_soon)).to be_due_soon
    end

    it "is false when overdue" do
      expect(build(:service_occurrence, :overdue)).not_to be_due_soon
    end
  end

  describe ".due_for_attention_by_equipment_kind" do
    it "groups due occurrences by equipment kind" do
      power_unit = create(:location_equipment, equipment: create(:equipment, :power_unit))
      ups = create(:location_equipment, equipment: create(:equipment, :ups))
      power_unit_occurrence = create(:service_occurrence, :overdue,
        location_equipment_service: power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "service"}))
      ups_occurrence = create(:service_occurrence, :overdue,
        location_equipment_service: ups.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "battery_change"}))

      grouped = described_class.due_for_attention_by_equipment_kind

      expect(grouped["power_unit"]).to include(power_unit_occurrence)
      expect(grouped["ups"]).to include(ups_occurrence)
    end
  end

  describe "#complete!" do
    let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }
    let(:recurring_les) { location_equipment.location_equipment_service_for(:service) }
    let!(:pending_occurrence) {
      recurring_les.service_occurrences.pending.destroy_all
      create(:service_occurrence, location_equipment_service: recurring_les, due_on: 1.month.from_now.to_date)
    }

    it "marks the occurrence completed and spawns the next pending for recurring services" do
      freeze_time
      completed_on = Date.current

      expect {
        pending_occurrence.complete!(completed_on: completed_on)
      }.to change(ServiceOccurrence.pending, :count).by(0) # one completed, one new pending

      expect(pending_occurrence.reload).to be_completed
      expect(pending_occurrence.completed_on).to eq(completed_on)
      next_pending = recurring_les.service_occurrences.pending.first
      expect(next_pending.due_on).to eq(recurring_les.advance(completed_on))
    end

    it "does not spawn a pending occurrence for one-time services" do
      one_time_kind = create(:service_kind, :one_time, name: "Inspección única")
      one_time_les = create(:location_equipment_service,
        location_equipment: location_equipment,
        service_kind: one_time_kind,
        interval: nil,
        interval_unit: nil)
      occurrence = create(:service_occurrence, location_equipment_service: one_time_les, due_on: 1.month.from_now.to_date)

      expect {
        occurrence.complete!(completed_on: Date.current)
      }.to change { one_time_les.service_occurrences.pending.count }.from(1).to(0)

      expect(one_time_les.service_occurrences.completed.count).to eq(1)
    end

    it "attaches a document to the completed occurrence" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")
      pending_occurrence.complete!(completed_on: Date.current, document: file)

      expect(pending_occurrence.reload.document).to be_attached
    end
  end

  describe "filtering" do
    let(:client_with_services) { create(:client) }
    let(:client_without_services) { create(:client) }
    let(:location_equipment) { create(:location_equipment, location: create(:location, client: client_with_services), equipment: create(:equipment, :power_unit)) }
    let(:service_kind) { ServiceKind.find_by!(legacy_key: "service") }
    let(:battery_change_kind) { ServiceKind.find_by!(legacy_key: "battery_change") }
    let!(:service_occurrence) do
      create(:service_occurrence, location_equipment_service: location_equipment.location_equipment_services.find_by!(service_kind: service_kind))
    end
    let!(:battery_change_occurrence) do
      create(:service_occurrence, location_equipment_service: location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind))
    end

    it "filters by service kind" do
      filtered = described_class.by_service_kind_id(service_kind.id)

      expect(filtered).to include(service_occurrence)
      expect(filtered).not_to include(battery_change_occurrence)
    end

    it "filters by client" do
      filtered = described_class.by_client_id(client_with_services.id)

      expect(filtered).to include(service_occurrence, battery_change_occurrence)
      expect(described_class.by_client_id(client_without_services.id)).to be_empty
    end
  end
end
