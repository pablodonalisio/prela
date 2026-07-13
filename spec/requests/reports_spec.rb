require "rails_helper"

RSpec.describe "Reports", type: :request do
  let(:report1) { create(:report, location_equipment: location_equipment) }
  let(:report2) { create(:report) }
  let(:params) do
    {report: {
      observations: "Test",
      date: Date.today,
      room_report_stat_attributes: {
        room_status: "Correcto",
        air_conditioning: "Correcto",
        temperature: 25.5,
        humidity: 50.5
      },
      images: [fixture_file_upload(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")]
    }.merge(equipment_report_params)}
  end
  let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, legacy_kind: equipment_kind), location: create(:location, name: "Sala de Máquinas de Resonador")) }
  let(:power_unit_report_params) do
    {
      power_unit_report_stat_attributes: {
        start_key_on_auto: "Auto",
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
    let(:equipment_kind) { "ups" }

    it "returns a successful response" do
      get location_equipment_report_path(report1.location_equipment, report1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    let(:equipment_kind) { "ups" }

    it "renders a successful response" do
      get new_location_equipment_report_path(report1.location_equipment)
      expect(response).to be_successful
    end

    it "allows to select a report date from 2016 to the current year" do
      get new_location_equipment_report_path(report1.location_equipment)
      expect(response.body).to include("option value=\"2016\"")
      expect(response.body).to include("option value=\"#{Date.today.year}\"")
      expect(response.body).not_to include("option value=\"#{Date.today.year + 1}\"")
      expect(response.body).not_to include("option value=\"2015\"")
    end
  end

  describe "GET /edit" do
    let(:equipment_kind) { "ups" }

    it "renders a successful response" do
      get edit_location_equipment_report_path(report1.location_equipment, report1)
      expect(response).to be_successful
    end

    it "allows to select a report date from 2016 to the current year" do
      get edit_location_equipment_report_path(report1.location_equipment, report1)
      expect(response.body).to include("option value=\"2016\"")
      expect(response.body).to include("option value=\"#{Date.today.year}\"")
      expect(response.body).not_to include("option value=\"#{Date.today.year + 1}\"")
      expect(response.body).not_to include("option value=\"2015\"")
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

      it "allows to create a report with a date from 2016" do
        freeze_time do
          params[:report][:date] = Date.new(2016, 1, 1)
          request
          expect(Report.last.date.to_date).to eq(Date.new(2016, 1, 1))
        end
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
    let(:equipment_kind) { "ups" }

    it "destroys the requested report" do
      report1
      expect {
        delete location_equipment_report_path(report1.location_equipment, report1)
      }.to change(Report, :count).by(-1)
    end
  end

  context "template-based report" do
    let(:equipment_kind) { "ups" }
    let(:report_template) { create(:report_template, :with_measurements, :with_tasks) }
    let(:template_params) do
      {
        report: {
          report_template_id: report_template.id,
          date: Date.today,
          field_values: {
            measurements: {"1739280000" => "220.5"}
          },
          images: [fixture_file_upload(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")]
        }
      }
    end

    describe "GET /new" do
      it "renders the template form when report_mode is template" do
        get new_location_equipment_report_path(location_equipment, report_mode: "template")
        expect(response).to be_successful
        expect(response.body).to include("Plantilla")
      end
    end

    describe "GET /template_fields" do
      it "returns dynamic fields for the selected template" do
        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)
        expect(response).to be_successful
        expect(response.body).to include("Tensión L1")
      end

      it "preloads template tasks for a new report" do
        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)
        expect(response.body).to include("Limpieza general")
        expect(response.body).to include("Verificación de torque")
        expect(response.body).to include("Protocolo de tareas")
      end

      it "preloads comments from the previous template report" do
        previous = create(:report, :template_based, location_equipment: location_equipment, report_template: report_template, date: 1.day.ago)
        create(:report_comment, report: previous, description: "Comentario heredado", position: 0)

        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)
        expect(response.body).to include("Comentario heredado")
        expect(response.body).to include("Comentarios y recomendaciones técnicas")
      end
    end

    describe "POST /create" do
      let(:request) do
        post location_equipment_reports_path(location_equipment), params: template_params
      end

      it "creates a template-based report" do
        expect { request }.to change(Report, :count).by(1)
        expect(Report.last.template_based?).to be true
        expect(Report.last.field_values.dig("measurements", "1739280000")).to eq("220.5")
      end

      it "seeds report tasks from the template" do
        expect { request }.to change(ReportTask, :count).by(2)
        expect(Report.last.report_tasks.order(:position).map(&:name)).to eq(
          ["Limpieza general", "Verificación de torque"]
        )
      end

      it "seeds comments from the previous template report" do
        previous = create(:report, :template_based, location_equipment: location_equipment, report_template: report_template, date: 1.day.ago)
        create(:report_comment, report: previous, description: "Comentario heredado", position: 0)

        expect { request }.to change(ReportComment, :count).by(1)
        expect(Report.order(:id).last.report_comments.map(&:description)).to eq(["Comentario heredado"])
      end

      it "does not attach a PDF" do
        request
        expect(Report.last.pdf).not_to be_attached
      end

      it "uploads images to the report" do
        request
        expect(Report.last.images).to be_attached
      end

      it "auto-assigns the template to the location equipment" do
        request
        expect(location_equipment.reload.report_templates).to include(report_template)
      end
    end

    describe "PATCH /update" do
      let(:template_report) { create(:report, :template_based, location_equipment: location_equipment, report_template: report_template) }
      let(:report_task) { template_report.report_tasks.find_by!(name: "Limpieza general") }
      let(:request) do
        patch location_equipment_report_path(location_equipment, template_report),
          params: {
            report: {
              date: Date.today,
              report_template_id: template_report.report_template_id,
              field_values: {
                measurements: {"1739280000" => "230.0"}
              },
              report_tasks_attributes: {
                report_task.id.to_s => {
                  id: report_task.id,
                  name: "Limpieza general",
                  completed: "1",
                  position: 0
                },
                "1739289999" => {
                  name: "Tarea adicional",
                  completed: "0",
                  position: 1
                }
              },
              report_comments_attributes: {
                "1739290000" => {
                  description: "Nuevo comentario",
                  position: 0
                }
              }
            }
          }
      end

      it "updates the template report" do
        request
        template_report.reload
        expect(template_report.field_values.dig("measurements", "1739280000")).to eq("230.0")
      end

      it "updates and adds report tasks" do
        existing_ids = template_report.report_tasks.pluck(:id)
        request
        template_report.reload
        expect(report_task.reload).to be_completed
        expect(template_report.report_tasks.map(&:name)).to include("Tarea adicional")
        expect(template_report.report_tasks.where.not(id: existing_ids).pluck(:name)).to eq(["Tarea adicional"])
      end

      it "adds report comments" do
        expect { request }.to change(ReportComment, :count).by(1)
        expect(template_report.reload.report_comments.map(&:description)).to include("Nuevo comentario")
      end

      it "does not attach a PDF" do
        request
        expect(template_report.reload.pdf).not_to be_attached
      end
    end

    describe "GET /show" do
      let(:template_report) do
        create(:report, :template_based, location_equipment: location_equipment, report_template: report_template).tap do |report|
          report.report_tasks.find_by!(name: "Limpieza general").update!(completed: true)
          create(:report_comment, report: report, description: "Comentario visible", position: 0)
        end
      end

      it "returns a successful response" do
        get location_equipment_report_path(location_equipment, template_report)
        expect(response).to have_http_status(:success)
      end

      it "renders the modern template report layout" do
        get location_equipment_report_path(location_equipment, template_report)
        equipment = location_equipment.equipment

        expect(response.body).to include("Informe de mantenimiento")
        expect(response.body).to include(location_equipment.client.name)
        expect(response.body).to include("Compañía / Cliente")
        expect(response.body).to include("Preventivo")
        expect(response.body).to include("1.0 Especificaciones del equipo")
        expect(response.body).to include(equipment.name)
        expect(response.body).to include(equipment.brand)
        expect(response.body).to include(location_equipment.location.name)
        expect(response.body).to include("Estado de parámetros físicos y mediciones")
        expect(response.body).to include("Tensión L1")
        expect(response.body).to include("Parámetro registrado")
        expect(response.body).to include("Imprimir / Guardar PDF")
      end

      it "renders the tasks checklist" do
        get location_equipment_report_path(location_equipment, template_report)
        expect(response.body).to include("Protocolo de tareas y acciones realizadas")
        expect(response.body).to include("Limpieza general")
        expect(response.body).to include("Verificación de torque")
        expect(response.body).to include("OK / Ejecutado")
        expect(response.body).to include("Pendiente")
      end

      it "renders the comments table when comments exist" do
        get location_equipment_report_path(location_equipment, template_report)
        expect(response.body).to include("Comentarios y recomendaciones técnicas")
        expect(response.body).to include("Comentario visible")
        expect(response.body).to include("Nº")
        expect(response.body).to include("Descripción")
      end

      it "omits the comments section when there are no comments" do
        ReportComment.where(report: template_report).delete_all
        get location_equipment_report_path(location_equipment, template_report)
        expect(response.body).not_to include("Comentarios y recomendaciones técnicas")
      end
    end

    describe "GET /edit" do
      let(:template_report) { create(:report, :template_based, location_equipment: location_equipment) }

      it "renders a successful response" do
        get edit_location_equipment_report_path(location_equipment, template_report)
        expect(response).to be_successful
      end
    end
  end
end
