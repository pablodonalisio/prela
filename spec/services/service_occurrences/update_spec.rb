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
    it "moves pending to scheduled with start and finish datetimes" do
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
      finish = init.change(hour: 10, min: 30)

      expect(
        described_class.call(
          occurrence,
          status: :scheduled,
          planned_on_init: init,
          planned_on_finish: finish
        )
      ).to be(true)

      occurrence.reload
      expect(occurrence).to be_scheduled
      expect(occurrence.planned_on_init).to eq(init)
      expect(occurrence.planned_on_finish).to eq(finish)
    end

    it "requires planned_on_init and planned_on_finish" do
      expect(described_class.call(occurrence, status: :scheduled)).to be(false)
      expect(occurrence.errors[:planned_on_init]).to be_present
      expect(occurrence.errors[:planned_on_finish]).to be_present
    end

    it "accepts a datetime-local value" do
      init = 1.week.from_now.change(hour: 9, min: 15, sec: 0)
      finish = init.change(hour: 10, min: 45)

      expect(
        described_class.call(
          occurrence,
          status: :scheduled,
          planned_on_init: init.strftime("%Y-%m-%dT%H:%M"),
          planned_on_finish: finish.strftime("%Y-%m-%dT%H:%M")
        )
      ).to be(true)

      occurrence.reload
      expect(occurrence.planned_on_init.strftime("%Y-%m-%dT%H:%M")).to eq(init.strftime("%Y-%m-%dT%H:%M"))
      expect(occurrence.planned_on_finish.strftime("%Y-%m-%dT%H:%M")).to eq(finish.strftime("%Y-%m-%dT%H:%M"))
    end

    it "accepts a finish on the next day" do
      init = 1.week.from_now.change(hour: 22, min: 0, sec: 0)
      finish = init.tomorrow.change(hour: 1, min: 0)

      expect(
        described_class.call(
          occurrence,
          status: :scheduled,
          planned_on_init: init,
          planned_on_finish: finish
        )
      ).to be(true)

      expect(occurrence.reload.planned_on_finish).to eq(finish)
    end

    it "rejects a finish that is not after the start" do
      init = 1.week.from_now.change(hour: 11, min: 0, sec: 0)

      expect(
        described_class.call(
          occurrence,
          status: :scheduled,
          planned_on_init: init,
          planned_on_finish: init.change(hour: 9)
        )
      ).to be(false)
      expect(occurrence.errors[:planned_on_finish]).to be_present
    end

    it "allows scheduling from suspended" do
      occurrence.update!(status: :suspended, notes: "blocked")
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)

      expect(
        described_class.call(
          occurrence,
          status: :scheduled,
          planned_on_init: init,
          planned_on_finish: init + 1.hour
        )
      ).to be(true)
      expect(occurrence.reload).to be_scheduled
    end
  end

  describe "revert" do
    it "returns scheduled to pending and clears the schedule, and updates notes" do
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
      occurrence.update!(status: :scheduled, planned_on_init: init, planned_on_finish: init.change(hour: 10, min: 30), notes: "Visita original")

      expect(described_class.call(occurrence, status: :pending, notes: "Reprogramar")).to be(true)

      occurrence.reload
      expect(occurrence).to be_pending
      expect(occurrence.planned_on_init).to be_nil
      expect(occurrence.planned_on_finish).to be_nil
      expect(occurrence.notes).to eq("Reprogramar")
    end
  end

  describe "invalid transitions" do
    it "rejects scheduled to suspended" do
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
      occurrence.update!(status: :scheduled, planned_on_init: init, planned_on_finish: init + 1.hour)

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

    it "completes from a scheduled occurrence and keeps the schedule" do
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
      finish = init.change(hour: 10, min: 30)
      occurrence.update!(status: :scheduled, planned_on_init: init, planned_on_finish: finish)

      expect(described_class.call(occurrence, status: :completed, completed_on: Date.current)).to be(true)
      occurrence.reload
      expect(occurrence).to be_completed
      expect(occurrence.planned_on_init).to eq(init)
      expect(occurrence.planned_on_finish).to eq(finish)
      expect(recurring_les.service_occurrences.pending).to exist
    end
  end

  describe "editing a completed occurrence" do
    before do
      described_class.call(occurrence, status: :completed, completed_on: Date.current)
    end

    it "updates completed_on and notes" do
      new_date = Date.yesterday

      expect(
        described_class.call(
          occurrence.reload,
          completed_on: new_date,
          notes: "Actualizado"
        )
      ).to be(true)

      occurrence.reload
      expect(occurrence.completed_on).to eq(new_date)
      expect(occurrence.due_on).to eq(new_date)
      expect(occurrence.notes).to eq("Actualizado")
      expect(occurrence).to be_completed
    end
  end
end
