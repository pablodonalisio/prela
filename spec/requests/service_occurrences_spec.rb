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
    let(:completion_params) {
      {completed_on: Date.current, start_time: "09:00", end_time: "11:00"}
    }

    it "completes the occurrence and refreshes the service dates section" do
      expect {
        post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
          params: {service_occurrence: completion_params},
          headers: {"Accept" => "text/vnd.turbo-stream.html"}
      }.to change { pending_occurrence.reload.status }.from("pending").to("completed")

      expect(pending_occurrence.start_time.strftime("%H:%M")).to eq("09:00")
      expect(pending_occurrence.end_time.strftime("%H:%M")).to eq("11:00")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("turbo-stream")
    end

    it "persists an uploaded document on the completed occurrence" do
      file = fixture_file_upload(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")

      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: completion_params.merge(document: file)}

      expect(pending_occurrence.reload.document).to be_attached
    end

    it "rejects completion without start and end times" do
      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: Date.current}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(pending_occurrence.reload).to be_pending
    end

    it "rejects completion without a date and shows a field error" do
      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: "", start_time: "09:00", end_time: "11:00"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('target="remote_modal_body"')
      expect(response.body).to include("Fecha de realización")
      expect(response.body).to include("no puede estar en blanco")
      expect(pending_occurrence.reload).to be_pending
    end
  end

  describe "GET /complete" do
    it "renders the date and required time pickers on one row" do
      get complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Fecha de realización")
      expect(response.body).to include("Hora de inicio")
      expect(response.body).to include("Hora de finalización")
      expect(response.body).to include("flex items-start gap-3")
      expect(response.body.scan('type="time"').size).to eq(2)
    end
  end

  describe "PATCH /update" do
    let(:new_due_on) { 2.months.from_now.to_date }

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

    it "schedules the occurrence" do
      planned_on = 1.week.from_now.to_date

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {
          intent: "schedule",
          service_occurrence: {status: "scheduled", planned_on: planned_on, start_time: "09:00", end_time: "11:00"}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence).to be_scheduled
      expect(pending_occurrence.planned_on).to eq(planned_on)
      expect(pending_occurrence.start_time.strftime("%H:%M")).to eq("09:00")
      expect(pending_occurrence.end_time.strftime("%H:%M")).to eq("11:00")
      expect(response).to have_http_status(:success)
    end

    it "renders required time pickers on the schedule form" do
      get edit_location_equipment_service_occurrence_path(location_equipment, pending_occurrence, intent: "schedule")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Fecha programada")
      expect(response.body).to include("Hora de inicio")
      expect(response.body).to include("Hora de finalización")
      expect(response.body).to include("flex items-start gap-3")
      expect(response.body.scan('type="time"').size).to eq(2)
    end

    it "reverts a scheduled occurrence to pending" do
      pending_occurrence.update!(status: :scheduled, planned_on: 1.week.from_now.to_date, start_time: "09:00", end_time: "11:00")

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {intent: "revert", service_occurrence: {status: "pending"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence).to be_pending
      expect(pending_occurrence.planned_on).to be_nil
      expect(pending_occurrence.start_time).to be_nil
      expect(pending_occurrence.end_time).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "updates a completed occurrence" do
      pending_occurrence.update!(
        status: :completed,
        completed_on: Date.current,
        due_on: Date.current,
        start_time: "09:00",
        end_time: "11:00"
      )

      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {
          intent: "completed",
          service_occurrence: {completed_on: Date.yesterday, notes: "Corregido", start_time: "08:30", end_time: "10:00"}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      pending_occurrence.reload
      expect(pending_occurrence.completed_on).to eq(Date.yesterday)
      expect(pending_occurrence.notes).to eq("Corregido")
      expect(pending_occurrence.start_time.strftime("%H:%M")).to eq("08:30")
      expect(pending_occurrence.end_time.strftime("%H:%M")).to eq("10:00")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("service_occurrences")
    end

    it "renders required time pickers on the completed edit form" do
      pending_occurrence.update!(
        status: :completed,
        completed_on: Date.current,
        due_on: Date.current,
        start_time: "09:00",
        end_time: "11:00"
      )

      get edit_location_equipment_service_occurrence_path(location_equipment, pending_occurrence, intent: "completed")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Fecha de realización")
      expect(response.body).to include("Hora de inicio")
      expect(response.body).to include("Hora de finalización")
      expect(response.body).to include("flex items-start gap-3")
      expect(response.body.scan('type="time"').size).to eq(2)
    end
  end

  context "when user is a client" do
    let(:user) { create(:user) }

    it "does not allow completing a service" do
      post complete_location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {completed_on: Date.current, start_time: "09:00", end_time: "11:00"}}

      expect(response).to redirect_to(root_path)
      expect(pending_occurrence.reload).to be_pending
    end
  end
end
