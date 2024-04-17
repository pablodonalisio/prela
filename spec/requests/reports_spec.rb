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
    let(:params) do
      {report: {
        observations: "Test",
        ups_report_stat_attributes: {
          operating_mode: "Normal",
          associated_charge: 10,
          battery_charge: 100,
          voltage_input: 230,
          voltage_output: 225,
          pat_state: "Correcto",
          alarms_presence: "Ninguna",
          ventilation_state: "Normal"
        },
        room_report_stat_attributes: {
          room_status: "Normal",
          air_conditioning: "Normal"
        },
        images: [fixture_file_upload(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")]
      }}
    end
    let(:request) do
      post location_equipment_reports_path(create(:location_equipment)), params: params
    end

    it "creates a new Report" do
      expect {
        request
      }.to change(Report, :count).by(1)
    end

    it "creates a new UPS Report Stat" do
      request
      expect(Report.last.ups_report_stat).to be_present
      expect(Report.last.ups_report_stat.attributes).to include(params[:report][:ups_report_stat_attributes].stringify_keys)
    end

    it "creates a new Room Report Stat" do
      request
      expect(Report.last.room_report_stat).to be_present
      expect(Report.last.room_report_stat.attributes).to include(params[:report][:room_report_stat_attributes].stringify_keys)
    end

    it "attaches a PDF file to the report" do
      request
      expect(Report.last.pdf).to be_attached
    end

    it "uploads images to the report" do
      request
      expect(Report.last.images).to be_attached
    end
  end

  describe "PATCH /update" do
    let(:request) do
      patch location_equipment_report_path(report1.location_equipment, report1), params:
    end
    let(:params) do
      {report:
        {
          observations: "Test",
          ups_report_stat_attributes: {
            operating_mode: "Fuera de servicio",
            associated_charge: 10,
            battery_charge: 80,
            voltage_input: 230,
            voltage_output: 225
          },
          room_report_stat_attributes: {
            room_status: "Elementos ajenos a la sala"
          }
        }}
    end

    it "updates the requested report" do
      request
      report1.reload
      expect(report1.observations).to eq("Test")
    end

    it "edits the UPS Report Stat" do
      request
      expect(report1.ups_report_stat.attributes).to include(params[:report][:ups_report_stat_attributes].stringify_keys)
    end

    it "edits the Room Report Stat" do
      request
      expect(report1.room_report_stat.attributes).to include(params[:report][:room_report_stat_attributes].stringify_keys)
    end

    it "attaches new PDF file to the report" do
      request
      expect(report1.pdf).to be_attached
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
