require "rails_helper"

RSpec.describe "Reports", type: :request do
  let(:report1) { create(:report) }
  let(:report2) { create(:report) }
  let(:params) do
    {report: {
      observations: "Test",
      date: Date.today,
      room_report_stat_attributes: {
        room_status: "Correcto",
        air_conditioning: "Correcto"
      },
      images: [fixture_file_upload(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")]
    }.merge(equipment_report_params)}
  end
  let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, kind: equipment_kind), location: create(:location, name: "Sala de Máquinas de Resonador")) }
  let(:power_unit_report_params) do
    {
      power_unit_report_stat_attributes: {
        start_key_on_auto: "ON",
        rpm: 1500,
        frequency: 50.0,
        battery_charge_control: 26.0,
        tension_between_phases_a_b: 380,
        tension_between_phases_b_c: 380,
        tension_between_phases_c_a: 380,
        initial_temperature: 20.0,
        running_temperature: 40.0,
        number_of_starts: 10,
        operating_time: 10,
        failed_starts: 0,
        oil_pressure: 4.0,
        fuel_level: "4",
        coolant_level: "Bajo",
        oil_level: "100",
        testing_time: 10,
        lamp_test: "Bien",
        belt_condition: "Bien",
        air_filter_condition: "Bien",
        anti_vibration_pad_condition: "Bien",
        liquids_leaks: "No",
        connections_condition_and_battery_fixation: "OK",
        cable_and_electrical_connections: "OK",
        general_disconnector: "ON",
        emergency_stop_position: "OFF",
        oil_pressure_unit: "bar"
      }
    }
  end
  let(:ups_report_params) do
    {
      ups_report_stat_attributes: {
        operating_mode: "Normal",
        associated_charge: 10,
        battery_charge: 100,
        voltage_input: 230,
        voltage_output: 225,
        pat_state: "Correcto",
        alarms_presence: "No",
        ventilation_state: "Bien"
      }
    }
  end
  let(:equipment_report_params) { send("#{equipment_kind}_report_params") }

  before { sign_in create(:admin) }

  describe "GET /show" do
    it "returns a successful response" do
      get location_equipment_report_path(report1.location_equipment, report1)
      expect(response).to have_http_status(:success)
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
    let(:request) do
      post location_equipment_reports_path(location_equipment), params: params
    end

    shared_examples "a successful report" do
      it "creates a new Report" do
        expect {
          request
        }.to change(Report, :count).by(1)
      end

      it "creates a new Room Report Stat" do
        request
        expect(Report.last.room_report_stat).to be_present
        expect(Report.last.room_report_stat.attributes).to include(params[:report][:room_report_stat_attributes].stringify_keys)
      end

      it "attaches a PDF file to the report" do
        location_equipment.client.avatar.attach Rack::Test::UploadedFile.new(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")
        request
        expect(Report.last.pdf).to be_attached
      end

      it "uploads images to the report" do
        request
        expect(Report.last.images).to be_attached
      end
    end

    context "when the equipment is a UPS" do
      let(:equipment_kind) { "ups" }

      it_behaves_like "a successful report"

      it "creates a new UPS Report Stat" do
        request
        expect(Report.last.ups_report_stat).to be_present
        expect(Report.last.ups_report_stat.attributes).to include(params[:report][:ups_report_stat_attributes].stringify_keys)
      end
    end

    context "when the equipment is a power unit" do
      let(:equipment_kind) { "power_unit" }

      it_behaves_like "a successful report"

      it "creates a new Power Unit Report Stat" do
        request

        expect(Report.last.power_unit_report_stat).to be_present
        expect(Report.last.power_unit_report_stat.attributes).to include(params[:report][:power_unit_report_stat_attributes].stringify_keys)
      end
    end
  end

  describe "PATCH /update" do
    let(:request) do
      patch location_equipment_report_path(report1.location_equipment, report1), params:
    end

    shared_examples "a successful update" do
      it "updates the requested report" do
        request
        report1.reload
        expect(report1.observations).to eq("Test")
      end

      it "edits the Room Report Stat" do
        request
        expect(report1.room_report_stat.attributes).to include(params[:report][:room_report_stat_attributes].stringify_keys)
      end

      it "attaches new PDF file to the report" do
        report1.location_equipment.client.avatar.attach Rack::Test::UploadedFile.new(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")
        request
        expect(report1.pdf).to be_attached
      end
    end

    context "when the equipment is a UPS" do
      let(:equipment_kind) { "ups" }

      it_behaves_like "a successful update"

      it "edits the UPS Report Stat" do
        request
        expect(report1.ups_report_stat.attributes).to include(params[:report][:ups_report_stat_attributes].stringify_keys)
      end
    end

    context "when the equipment is a power unit" do
      let(:equipment_kind) { "power_unit" }

      it_behaves_like "a successful update"

      it "edits the Power Unit Report Stat" do
        request
        expect(report1.power_unit_report_stat.attributes).to include(params[:report][:power_unit_report_stat_attributes].stringify_keys)
      end
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
