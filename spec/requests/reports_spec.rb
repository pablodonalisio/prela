require "rails_helper"

RSpec.describe "Reports", type: :request do
  let(:report1) { create(:report) }
  let(:report2) { create(:report) }

  before { sign_in create(:user) }

  describe "GET /show" do
    it "returns a successful response and display the report" do
      get location_equipment_report_path(report1.location_equipment, report1)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(report1.location_equipment.model)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_location_equipment_report_path(report1.location_equipment)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_location_equipment_report_path(report1.location_equipment, report1)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    it "creates a new Report" do
      expect {
        post location_equipment_reports_path(create(:location_equipment)), params: {report: {observations: "Test"}}
      }.to change(Report, :count).by(1)
    end
  end

  describe "PATCH /update" do
    it "updates the requested report" do
      patch location_equipment_report_path(report1.location_equipment, report1), params: {report: {observations: "Test"}}
      report1.reload
      expect(report1.observations).to eq("Test")
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested report" do
      report1
      expect {
        delete location_equipment_report_path(report1.location_equipment, report1)
      }.to change(Report, :count).by(-1)
    end
  end
end
