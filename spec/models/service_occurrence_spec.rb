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

  it "allows only one open occurrence per location equipment service" do
    les = create(:location_equipment_service)
    create(:service_occurrence, location_equipment_service: les)

    duplicate = build(:service_occurrence, location_equipment_service: les)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:status]).to be_present
  end

  it "allows a completed occurrence alongside a new open one" do
    les = create(:location_equipment_service)
    create(:service_occurrence, :completed, location_equipment_service: les)
    open = build(:service_occurrence, location_equipment_service: les)

    expect(open).to be_valid
  end

  it "requires planned_on when scheduled" do
    occurrence = build(:service_occurrence, status: :scheduled, planned_on: nil)

    expect(occurrence).not_to be_valid
    expect(occurrence.errors[:planned_on]).to be_present
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

  describe ".actionable_for_attention" do
    it "includes pending due soon or overdue but not suspended or scheduled" do
      overdue = create(:service_occurrence, :overdue)
      due_soon = create(:service_occurrence, :due_soon)
      create(:service_occurrence, :overdue, status: :suspended)
      create(:service_occurrence, :scheduled)
      create(:service_occurrence, due_on: 4.months.from_now.to_date)

      expect(described_class.actionable_for_attention).to contain_exactly(overdue, due_soon)
    end
  end

  describe ".due_for_attention" do
    it "includes overdue and due soon open occurrences including suspended" do
      overdue = create(:service_occurrence, :overdue)
      due_soon = create(:service_occurrence, :due_soon)
      suspended = create(:service_occurrence, :overdue, status: :suspended)
      create(:service_occurrence, due_on: 4.months.from_now.to_date)

      expect(described_class.due_for_attention).to contain_exactly(overdue, due_soon, suspended)
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

  describe ".suspended_by_equipment_kind" do
    it "groups suspended occurrences by equipment kind" do
      power_unit = create(:location_equipment, equipment: create(:equipment, :power_unit))
      les = power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "service"})
      les.service_occurrences.destroy_all
      suspended = create(:service_occurrence, :overdue, status: :suspended, location_equipment_service: les)

      grouped = described_class.suspended_by_equipment_kind

      expect(grouped["power_unit"]).to include(suspended)
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
