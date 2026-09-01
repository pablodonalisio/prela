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

    it "updates the pending due_on date" do
      patch location_equipment_service_occurrence_path(location_equipment, pending_occurrence),
        params: {service_occurrence: {due_on: new_due_on}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(pending_occurrence.reload.due_on).to eq(new_due_on)
      expect(response).to have_http_status(:success)
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
end
