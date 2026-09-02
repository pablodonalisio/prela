require "rails_helper"

RSpec.describe ServiceOccurrences::Update do
  before do
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
    allow_any_instance_of(LocationEquipment).to receive(:create_initial_pending_occurrences!).and_return(nil)
  end

  let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }
  let(:recurring_les) { location_equipment.location_equipment_service_for(:service) }
  let!(:occurrence) do
    recurring_les.service_occurrences.destroy_all
    create(:service_occurrence, location_equipment_service: recurring_les, due_on: 1.month.from_now.to_date)
  end

  describe "due_on update" do
    it "updates due_on while pending" do
      new_due_on = 2.months.from_now.to_date

      expect(described_class.call(occurrence, due_on: new_due_on)).to be(true)
      expect(occurrence.reload.due_on).to eq(new_due_on)
      expect(occurrence).to be_pending
    end

    it "rejects due_on updates when suspended" do
      occurrence.update!(status: :suspended)

      expect(described_class.call(occurrence, due_on: Date.current)).to be(false)
      expect(occurrence.errors[:due_on]).to be_present
    end
  end

  describe "suspend" do
    it "moves pending to suspended with notes" do
      expect(described_class.call(occurrence, status: :suspended, notes: "Espera cliente")).to be(true)

      occurrence.reload
      expect(occurrence).to be_suspended
      expect(occurrence.notes).to eq("Espera cliente")
    end
  end

  describe "schedule" do
    it "moves pending to scheduled with planned_on" do
      planned_on = 1.week.from_now.to_date

      expect(described_class.call(occurrence, status: :scheduled, planned_on: planned_on)).to be(true)

      occurrence.reload
      expect(occurrence).to be_scheduled
      expect(occurrence.planned_on).to eq(planned_on)
    end

    it "requires planned_on" do
      expect(described_class.call(occurrence, status: :scheduled)).to be(false)
      expect(occurrence.errors[:planned_on]).to be_present
    end

    it "accepts multiparameter planned_on from date selects" do
      planned_on = 1.week.from_now.to_date

      expect(
        described_class.call(
          occurrence,
          status: "scheduled",
          "planned_on(1i)" => planned_on.year.to_s,
          "planned_on(2i)" => planned_on.month.to_s,
          "planned_on(3i)" => planned_on.day.to_s
        )
      ).to be(true)

      expect(occurrence.reload.planned_on).to eq(planned_on)
    end

    it "allows scheduling from suspended" do
      occurrence.update!(status: :suspended, notes: "blocked")
      planned_on = 1.week.from_now.to_date

      expect(described_class.call(occurrence, status: :scheduled, planned_on: planned_on)).to be(true)
      expect(occurrence.reload).to be_scheduled
    end
  end

  describe "revert" do
    it "returns scheduled to pending and clears planned_on" do
      occurrence.update!(status: :scheduled, planned_on: 1.week.from_now.to_date)

      expect(described_class.call(occurrence, status: :pending)).to be(true)

      occurrence.reload
      expect(occurrence).to be_pending
      expect(occurrence.planned_on).to be_nil
    end
  end

  describe "invalid transitions" do
    it "rejects scheduled to suspended" do
      occurrence.update!(status: :scheduled, planned_on: 1.week.from_now.to_date)

      expect(described_class.call(occurrence, status: :suspended)).to be(false)
      expect(occurrence.errors[:status]).to be_present
      expect(occurrence.reload).to be_scheduled
    end
  end

  describe "complete" do
    it "marks completed and spawns the next pending for recurring services" do
      freeze_time
      completed_on = Date.current

      expect {
        described_class.call(occurrence, status: :completed, completed_on: completed_on)
      }.to change(ServiceOccurrence.pending, :count).by(0)

      expect(occurrence.reload).to be_completed
      expect(occurrence.completed_on).to eq(completed_on)
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
      one_time = create(:service_occurrence, location_equipment_service: one_time_les, due_on: 1.month.from_now.to_date)

      expect {
        described_class.call(one_time, status: :completed, completed_on: Date.current)
      }.to change { one_time_les.service_occurrences.pending.count }.from(1).to(0)

      expect(one_time_les.service_occurrences.completed.count).to eq(1)
    end

    it "attaches a document to the completed occurrence" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")

      described_class.call(occurrence, status: :completed, completed_on: Date.current, document: file)

      expect(occurrence.reload.document).to be_attached
    end

    it "completes from a scheduled occurrence" do
      occurrence.update!(status: :scheduled, planned_on: 1.week.from_now.to_date)

      expect(described_class.call(occurrence, status: :completed, completed_on: Date.current)).to be(true)
      expect(occurrence.reload).to be_completed
      expect(recurring_les.service_occurrences.pending).to exist
    end
  end
end
