require "rails_helper"

RSpec.describe "ServiceOccurrences", type: :request do
  let(:user) { create(:admin) }
  let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }

  before do
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
  end

  let(:les) { location_equipment.location_equipment_service_for(:service) }
  let!(:pending_occurrence) {
    les.service_occurrences.pending.destroy_all
    create(:service_occurrence, location_equipment_service: les, due_on: 1.month.from_now.to_date)
  }

  before do
    sign_in user
    ServiceKind.ensure_legacy_kinds!
  end

  describe "POST /complete" do
    it "completes the occurrence and refreshes the service dates section" do
      expect {
        post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
          params: {service_occurrence: {completed_on: Date.current}},
          headers: {"Accept" => "text/vnd.turbo-stream.html"}
      }.to change { pending_occurrence.reload.status }.from("pending").to("completed")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("turbo-stream")
    end

    it "persists an uploaded document on the completed occurrence" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")

      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: Date.current, document: file}}

      expect(pending_occurrence.reload.document).to be_attached
    end
  end

  describe "PATCH /update" do
    let(:new_due_on) { 2.months.from_now.to_date }

    it "updates the occurrence priority from the priority form" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "priority", service_occurrence: {priority: "critical"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(pending_occurrence.reload.priority).to eq("critical")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("La prioridad se actualizó correctamente.")
    end

    it "does not change priority from a service action" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "due_on", service_occurrence: {due_on: new_due_on, priority: "critical"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence.due_on).to eq(new_due_on)
      expect(pending_occurrence.priority).to eq("normal")
    end

    it "updates the pending due_on date" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "due_on", service_occurrence: {due_on: new_due_on}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(pending_occurrence.reload.due_on).to eq(new_due_on)
      expect(response).to have_http_status(:success)
    end

    it "suspends the occurrence" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "suspend", service_occurrence: {status: "suspended", notes: "Espera cliente"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence).to be_suspended
      expect(pending_occurrence.notes).to eq("Espera cliente")
      expect(response).to have_http_status(:success)
    end

    it "schedules the occurrence with start and finish datetimes" do
      init = 1.week.from_now.change(hour: 8, min: 30, sec: 0)
      finish = init.change(hour: 11, min: 0)

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {
          intent: "schedule",
          service_occurrence: {
            status: "scheduled",
            planned_on_init: init.strftime("%Y-%m-%dT%H:%M"),
            planned_on_finish: finish.strftime("%Y-%m-%dT%H:%M")
          }
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence).to be_scheduled
      expect(pending_occurrence.planned_on_init.strftime("%Y-%m-%dT%H:%M")).to eq(init.strftime("%Y-%m-%dT%H:%M"))
      expect(pending_occurrence.planned_on_finish.strftime("%Y-%m-%dT%H:%M")).to eq(finish.strftime("%Y-%m-%dT%H:%M"))
      expect(response).to have_http_status(:success)
      expect(response.body).to include("08:30")
      expect(response.body).to include("11:00")
    end

    it "rejects a schedule without datetimes" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "schedule", service_occurrence: {status: "scheduled"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(pending_occurrence.reload).to be_pending
      expect(response.body).to include("Inicio programado")
      expect(response.body).to include("Fin programado")
      expect(response.body).to include("no puede estar en blanco")
    end

    it "reverts a scheduled occurrence to pending" do
      init = 1.week.from_now.change(hour: 9, min: 0, sec: 0)
      pending_occurrence.update!(
        status: :scheduled,
        planned_on_init: init,
        planned_on_finish: init + 1.hour,
        notes: "Visita original"
      )

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "revert", service_occurrence: {status: "pending", notes: "Reprogramar la semana que viene"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence).to be_pending
      expect(pending_occurrence.planned_on_init).to be_nil
      expect(pending_occurrence.planned_on_finish).to be_nil
      expect(pending_occurrence.notes).to eq("Reprogramar la semana que viene")
      expect(response).to have_http_status(:success)
    end

    it "updates a completed occurrence" do
      pending_occurrence.update!(status: :completed, completed_on: Date.current, due_on: Date.current)

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {
          intent: "completed",
          service_occurrence: {completed_on: Date.yesterday, notes: "Corregido"}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence.completed_on).to eq(Date.yesterday)
      expect(pending_occurrence.notes).to eq("Corregido")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("service_occurrences")
    end
  end

  context "when user is a client" do
    let(:user) { create(:user) }

    it "does not allow completing a service" do
      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: Date.current}}

      expect(response).to redirect_to(root_path)
      expect(pending_occurrence.reload).to be_pending
    end
  end

  context "when user is a technician" do
    let(:user) { create(:technician, editor: true) }

    it "completes the occurrence" do
      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: Date.current}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:success)
      expect(pending_occurrence.reload).to be_completed
    end

    it "does not allow updating the occurrence" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "suspend", service_occurrence: {status: "suspended", notes: "No"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to redirect_to(root_path)
      expect(pending_occurrence.reload).to be_pending
    end

    it "shows the complete action and hides schedule and suspend" do
      get location_equipment_path(location_equipment)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Registrar servicio")
      expect(response.body).not_to include("Programar")
      expect(response.body).not_to include("Suspender")
    end
  end
end
