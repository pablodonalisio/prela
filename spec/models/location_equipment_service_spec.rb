require "rails_helper"

RSpec.describe LocationEquipmentService, type: :model do
  it "is valid with required attributes" do
    expect(build(:location_equipment_service)).to be_valid
  end

  it "is not valid with a non-positive interval when recurring" do
    expect(build(:location_equipment_service, interval: 0)).not_to be_valid
  end

  it "is valid as one-time without interval fields" do
    service_kind = create(:service_kind, :one_time)
    les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
    expect(les).to be_valid
  end

  it "clears interval fields when the service kind is one-time" do
    service_kind = create(:service_kind, :one_time)
    les = build(:location_equipment_service, service_kind: service_kind, interval: 1, interval_unit: :years)
    expect(les).to be_valid
    expect(les.interval).to be_nil
    expect(les.interval_unit).to be_nil
  end

  it "prefills interval from the service kind when recurring" do
    service_kind = create(:service_kind, default_interval: 3, interval_unit: :months)
    les = LocationEquipmentService.new(
      location_equipment: create(:location_equipment),
      service_kind: service_kind
    )
    expect(les).to be_valid
    expect(les.interval).to eq(3)
    expect(les.interval_unit).to eq("months")
  end

  it "allows any visible service kind on a location equipment" do
    location_equipment = create(:location_equipment)
    foreign_kind = create(:service_kind)
    les = LocationEquipmentService.new(
      location_equipment: location_equipment,
      service_kind: foreign_kind,
      interval: 1,
      interval_unit: :years
    )

    expect(les).to be_valid
  end

  describe "#apply_service_kind_defaults!" do
    it "sets interval and unit from the service kind" do
      service_kind = create(:service_kind, default_interval: 4, interval_unit: :months)
      les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)

      les.apply_service_kind_defaults!

      expect(les.interval).to eq(4)
      expect(les.interval_unit).to eq("months")
    end

    it "clears interval fields for one-time service kinds" do
      service_kind = create(:service_kind, :one_time)
      les = build(:location_equipment_service, service_kind: service_kind, interval: 2, interval_unit: :years)

      les.apply_service_kind_defaults!

      expect(les.interval).to be_nil
      expect(les.interval_unit).to be_nil
    end
  end

  describe "#last_completed_on and #next_due_on" do
    let(:les) { create(:location_equipment_service, interval: 1, interval_unit: :years) }

    it "returns the latest completed occurrence date" do
      les.service_occurrences.destroy_all
      create(:service_occurrence, :completed, location_equipment_service: les, completed_on: 1.year.ago.to_date, due_on: 1.year.ago.to_date)
      create(:service_occurrence, :completed, location_equipment_service: les, completed_on: Date.current, due_on: Date.current)

      expect(les.last_completed_on).to eq(Date.current)
    end

    it "returns the pending occurrence due_on" do
      les.service_occurrences.destroy_all
      create(:service_occurrence, location_equipment_service: les, due_on: 2.months.from_now.to_date)

      expect(les.next_due_on).to eq(2.months.from_now.to_date)
    end
  end

  describe "#advance" do
    it "advances by years" do
      les = build(:location_equipment_service, interval: 2, interval_unit: :years)
      expect(les.advance(Date.new(2024, 1, 15)).to_date).to eq(Date.new(2026, 1, 15))
    end

    it "advances by months" do
      les = build(:location_equipment_service, interval: 6, interval_unit: :months)
      expect(les.advance(Date.new(2024, 1, 15)).to_date).to eq(Date.new(2024, 7, 15))
    end

    it "advances by weeks" do
      les = build(:location_equipment_service, interval: 2, interval_unit: :weeks)
      expect(les.advance(Date.new(2024, 1, 1)).to_date).to eq(Date.new(2024, 1, 15))
    end

    it "returns nil for one-time services" do
      service_kind = build(:service_kind, :one_time)
      les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
      expect(les.advance(Date.new(2024, 1, 1))).to be_nil
    end
  end

  describe "#unassign!" do
    let(:les) { create(:location_equipment_service, interval: 1, interval_unit: :years) }

    before { les.service_occurrences.destroy_all }

    it "drops pending and scheduled occurrences" do
      pending = create(:service_occurrence, location_equipment_service: les, due_on: Date.yesterday)
      scheduled_les = create(:location_equipment_service, interval: 1, interval_unit: :years)
      scheduled_les.service_occurrences.destroy_all
      scheduled = create(:service_occurrence, :scheduled, location_equipment_service: scheduled_les)

      les.unassign!
      scheduled_les.unassign!

      expect(ServiceOccurrence.exists?(pending.id)).to be(false)
      expect(ServiceOccurrence.exists?(scheduled.id)).to be(false)
      expect(LocationEquipmentService.exists?(les.id)).to be(false)
      expect(LocationEquipmentService.exists?(scheduled_les.id)).to be(false)
    end

    it "keeps completed occurrences and cancelled or suspended ones due today or earlier" do
      completed = create(:service_occurrence, :completed, location_equipment_service: les, completed_on: 1.year.ago.to_date, due_on: 1.year.ago.to_date)
      cancelled_today = create(:service_occurrence, location_equipment_service: les, status: :cancelled, due_on: Date.current)
      future_cancelled = create(:service_occurrence, location_equipment_service: les, status: :cancelled, due_on: Date.tomorrow)
      suspended = create(:service_occurrence, :suspended, location_equipment_service: les, due_on: Date.yesterday)

      les.unassign!

      expect(les.reload).to be_removed
      expect(completed.reload.completed_on).to eq(1.year.ago.to_date)
      expect(completed).to be_completed
      expect(cancelled_today.reload).to be_cancelled
      expect(suspended.reload).to be_suspended
      expect(ServiceOccurrence.exists?(future_cancelled.id)).to be(false)
    end

    it "keeps a past occurrence in the equipment history and drops it from operational lists" do
      suspended = create(:service_occurrence, :suspended, location_equipment_service: les, due_on: Date.current)

      expect(ServiceOccurrence.for_visible_location_equipments.where(id: suspended.id)).to exist

      les.unassign!

      expect(les.location_equipment.service_occurrences).to include(suspended)
      expect(les.location_equipment.open_service_occurrences).not_to include(suspended)
      expect(ServiceOccurrence.for_visible_location_equipments.where(id: suspended.id)).to be_empty
    end

    it "drops a suspended occurrence due after today" do
      future_suspended = create(:service_occurrence, :suspended, location_equipment_service: les, due_on: Date.tomorrow)

      les.unassign!

      expect(ServiceOccurrence.exists?(future_suspended.id)).to be(false)
      expect(LocationEquipmentService.exists?(les.id)).to be(false)
    end

    it "leaves completed occurrences unchanged when the service is assigned again" do
      completed = create(:service_occurrence, :completed, location_equipment_service: les, completed_on: 6.months.ago.to_date, due_on: 6.months.ago.to_date, notes: "Hecho")
      create(:service_occurrence, location_equipment_service: les, due_on: Date.current)

      les.unassign!
      les.update!(removed_at: nil, interval: 4, interval_unit: :months)
      les.due_on = 2.weeks.from_now.to_date
      pending = les.create_pending_occurrence!

      expect(les.reload).to be_active
      expect(les.interval).to eq(4)
      expect(pending.due_on).to eq(2.weeks.from_now.to_date)
      expect(completed.reload.notes).to eq("Hecho")
      expect(completed.completed_on).to eq(6.months.ago.to_date)
      expect(completed).to be_completed
    end

    it "does not create another occurrence when an open one is still there" do
      suspended = create(:service_occurrence, :suspended, location_equipment_service: les, due_on: Date.current, notes: "En pausa")

      les.unassign!
      les.update!(removed_at: nil)
      les.due_on = 1.month.from_now.to_date

      expect(les.create_pending_occurrence!).to be_nil
      expect(suspended.reload.notes).to eq("En pausa")
      expect(les.service_occurrences.open).to contain_exactly(suspended)
    end
  end

  describe "#interval_label" do
    it "combines interval and unit" do
      les = build(:location_equipment_service, interval: 3, interval_unit: :months)
      expect(les.interval_label).to eq("3 meses")
    end

    it "returns the one-time label when not recurring" do
      service_kind = build(:service_kind, :one_time)
      les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
      expect(les.interval_label).to eq("Único")
    end
  end
end
