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

  it "uses the same priority values as service kinds" do
    expect(described_class.priorities).to eq(ServiceKind.priorities)
  end

  it "copies priority from the service kind on create" do
    service_kind = create(:service_kind, :critical)
    les = create(:location_equipment_service, service_kind: service_kind)
    occurrence = create(:service_occurrence, location_equipment_service: les)

    expect(occurrence.priority).to eq("critical")
  end

  it "uses the service kind priority even when one is passed on create" do
    service_kind = create(:service_kind, :critical)
    les = create(:location_equipment_service, service_kind: service_kind)
    occurrence = create(:service_occurrence, location_equipment_service: les, priority: :low)

    expect(occurrence.priority).to eq("critical")
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

  it "requires planned_on_init and planned_on_finish when scheduled" do
    occurrence = build(:service_occurrence, status: :scheduled, planned_on_init: nil, planned_on_finish: nil)

    expect(occurrence).not_to be_valid
    expect(occurrence.errors[:planned_on_init]).to be_present
    expect(occurrence.errors[:planned_on_finish]).to be_present
  end

  it "requires the finish to be after the start" do
    init = 1.week.from_now.change(hour: 18, min: 0, sec: 0)
    occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, planned_on_finish: init.change(hour: 9))

    expect(occurrence).not_to be_valid
    expect(occurrence.errors[:planned_on_finish]).to be_present
  end

  it "rejects a start before today" do
    init = 1.day.ago.change(hour: 9, min: 0, sec: 0)
    occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, planned_on_finish: init + 1.hour)

    expect(occurrence).not_to be_valid
    expect(occurrence.errors[:planned_on_init]).to be_present
  end

  it "allows a start today" do
    init = Time.current.beginning_of_day.change(hour: 8)
    occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, planned_on_finish: init + 1.hour)

    expect(occurrence).to be_valid
  end

  it "allows the finish to fall on a later day" do
    init = 1.week.from_now.change(hour: 18, min: 0, sec: 0)
    occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, planned_on_finish: init.tomorrow.change(hour: 9))

    expect(occurrence).to be_valid
  end

  it "clears the schedule when pending, suspended, or cancelled" do
    occurrence = create(:service_occurrence, :scheduled)
    init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
    finish = init + 90.minutes

    %i[suspended pending cancelled].each do |status|
      occurrence.update!(status: status, planned_on_init: init, planned_on_finish: finish)

      expect(occurrence.reload.planned_on_init).to be_nil
      expect(occurrence.planned_on_finish).to be_nil

      occurrence.update!(status: :scheduled, planned_on_init: init, planned_on_finish: finish)
    end
  end

  it "keeps the schedule when completed" do
    occurrence = create(:service_occurrence, :scheduled)
    init = occurrence.planned_on_init
    finish = occurrence.planned_on_finish

    occurrence.update!(status: :completed, completed_on: Date.current, due_on: Date.current)

    expect(occurrence.reload.planned_on_init).to eq(init)
    expect(occurrence.planned_on_finish).to eq(finish)
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

  describe "#service_date" do
    it "uses planned_on_init when scheduled" do
      init = Time.current.change(hour: 9, min: 0, sec: 0)
      occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, due_on: 1.month.from_now.to_date)

      expect(occurrence.service_date).to eq(init)
    end

    it "uses completed_on when completed" do
      occurrence = build(:service_occurrence, :completed, completed_on: Date.yesterday, due_on: Date.yesterday)

      expect(occurrence.service_date).to eq(Date.yesterday)
    end

    it "uses due_on when pending" do
      occurrence = build(:service_occurrence, due_on: Date.current)

      expect(occurrence.service_date).to eq(Date.current)
    end
  end

  describe "#agenda_date" do
    it "uses planned_on_init when scheduled" do
      init = Time.current.change(hour: 9, min: 0, sec: 0)
      occurrence = build(:service_occurrence, :scheduled, planned_on_init: init, due_on: 1.month.from_now.to_date)

      expect(occurrence.agenda_date).to eq(init)
    end

    it "uses due_on when pending or suspended" do
      pending = build(:service_occurrence, due_on: Date.current)
      suspended = build(:service_occurrence, :suspended, due_on: Date.yesterday)

      expect(pending.agenda_date).to eq(Date.current)
      expect(suspended.agenda_date).to eq(Date.yesterday)
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

  describe ".control_panel_by_equipment_kind" do
    it "groups actionable and suspended occurrences by equipment kind" do
      power_unit = create(:location_equipment, equipment: create(:equipment, :power_unit))
      les = power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "service"})
      les.service_occurrences.destroy_all
      overdue = create(:service_occurrence, :overdue, location_equipment_service: les)

      battery_les = power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "battery_change"})
      battery_les.service_occurrences.destroy_all
      suspended = create(:service_occurrence, :overdue, status: :suspended, location_equipment_service: battery_les)

      grouped = described_class.control_panel_by_equipment_kind
      occurrences = grouped[power_unit.equipment.equipment_kind]

      expect(occurrences).to include(overdue, suspended)
    end
  end

  describe ".due_for_attention_by_equipment_kind" do
    it "groups due occurrences by equipment kind record" do
      power_unit = create(:location_equipment, equipment: create(:equipment, :power_unit))
      ups = create(:location_equipment, equipment: create(:equipment, :ups))
      power_unit_occurrence = create(:service_occurrence, :overdue,
        location_equipment_service: power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "service"}))
      ups_occurrence = create(:service_occurrence, :overdue,
        location_equipment_service: ups.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "battery_change"}))

      grouped = described_class.due_for_attention_by_equipment_kind

      expect(grouped[power_unit.equipment.equipment_kind]).to include(power_unit_occurrence)
      expect(grouped[ups.equipment.equipment_kind]).to include(ups_occurrence)
    end
  end

  describe ".suspended_by_equipment_kind" do
    it "groups suspended occurrences by equipment kind record" do
      power_unit = create(:location_equipment, equipment: create(:equipment, :power_unit))
      les = power_unit.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "service"})
      les.service_occurrences.destroy_all
      suspended = create(:service_occurrence, :overdue, status: :suspended, location_equipment_service: les)

      grouped = described_class.suspended_by_equipment_kind

      expect(grouped[power_unit.equipment.equipment_kind]).to include(suspended)
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

    it "filters by priority" do
      service_occurrence.update!(priority: :critical)
      battery_change_occurrence.update!(priority: :low)

      filtered = described_class.by_priority(:critical)

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
