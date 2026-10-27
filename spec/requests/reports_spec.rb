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
      expect(response.body).to include('min="2016-01-01"')
      expect(response.body).to include(%(max="#{Date.current.year}-12-31"))
      expect(response.body).not_to include('min="2015-01-01"')
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
      expect(response.body).to include('min="2016-01-01"')
      expect(response.body).to include(%(max="#{Date.current.year}-12-31"))
      expect(response.body).not_to include('min="2015-01-01"')
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
    let(:report_template) { create(:report_template, :with_measurements, :with_list) }
    let(:measurement_section) { report_template.sections.find_by!(title: "Tensión L1") }
    let(:photos_section) { report_template.sections.find_by!(title: "Fotos") }
    let(:template_params) do
      {
        report: {
          report_template_id: report_template.id,
          date: Date.today,
          section_inputs: {
            measurement_section.id => {
              cells: {"0_1" => {value: "220.5"}}
            }
          }
        }
      }
    end

    describe "GET /new" do
      it "renders the template form when report_mode is template" do
        get new_location_equipment_report_path(location_equipment, report_mode: "template")
        expect(response).to be_successful
        expect(response.body).to include("Plantilla")
      end

      it "renders the text section with the wysiwyg editor and no image tools" do
        report_template
        get new_location_equipment_report_path(location_equipment, report_mode: "template")

        expect(response.body).to include('data-controller="wysiwyg"')
        expect(response.body).to include("Negrita")
        expect(response.body).to include("Formato")
        expect(response.body).not_to include("Agregar imagen")
        expect(response.body).not_to include('type="file"')
      end
    end

    describe "GET /template_fields" do
      it "returns boolean option labels for a boolean cell" do
        cell = measurement_section.table_section.table_cells.find_by!(row_index: 0, column_index: 1)
        cell.update!(value_type: "boolean", for_metrics: false, fixed: false)
        cell.table_cell_options.find_by!(value: true).update!(label: "Aprobado")
        cell.table_cell_options.find_by!(value: false).update!(label: "Rechazado")

        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)

        expect(response.body).to include("Aprobado")
        expect(response.body).to include("Rechazado")
        expect(response.body).to include('type="radio"')
      end

      it "returns dynamic fields for the selected template" do
        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)
        expect(response).to be_successful
        expect(response.body).to include("Tensión L1")
        expect(response.body).to include("Concepto")
        expect(response.body).to include("Fase")
        expect(response.body).to include("Línea 1")
      end

      it "shows list items with checkboxes" do
        get template_fields_location_equipment_reports_path(location_equipment, report_template_id: report_template.id)
        expect(response.body).to include("Protocolo")
        expect(response.body).to include("Limpieza general")
        expect(response.body).to include("Verificación de torque")
        expect(response.body).to include('type="checkbox"')
        expect(response.body).not_to include("Comentarios y recomendaciones técnicas")
      end
    end

    describe "POST /create" do
      let(:request) do
        post location_equipment_reports_path(location_equipment), params: template_params
      end

      it "creates a template-based report" do
        expect { request }.to change(Report, :count).by(1)
        expect(Report.last.template_based?).to be true
        cell = Report.last.sections.find_by!(title: "Tensión L1").table_section.cell_at(0, 1)
        expect(cell.value).to eq("220.5")
      end

      it "copies list items from the template" do
        request
        items = Report.last.sections.find_by!(title: "Protocolo").list_section.list_items.order(:position)
        expect(items.map(&:name)).to eq(["Limpieza general", "Verificación de torque"])
        expect(items.map(&:checked?)).to all(be false)
      end

      it "stores which list items were checked" do
        list_section = report_template.sections.find_by!(title: "Protocolo")
        item = list_section.list_section.list_items.find_by!(name: "Limpieza general")
        params = template_params.deep_merge(
          report: {
            section_inputs: {
              list_section.id => {
                items: {item.id => {checked: "1"}}
              }
            }
          }
        )

        post location_equipment_reports_path(location_equipment), params: params
        items = Report.last.sections.find_by!(title: "Protocolo").list_section.list_items.order(:position)
        expect(items.find_by!(name: "Limpieza general")).to be_checked
        expect(items.find_by!(name: "Verificación de torque")).not_to be_checked
      end

      it "does not attach a PDF" do
        request
        expect(Report.last.pdf).not_to be_attached
      end

      it "stores formatted text and drops images from the text section" do
        notes = report_template.sections.find_by!(title: "Notas")
        params = template_params.deep_merge(
          report: {
            section_inputs: {
              notes.id => {
                body: '<p>Hola <strong>equipo</strong></p><img src="data:image/png;base64,aaaa" alt="foto"><p style="background-image:url(https://evil.test/a.png)">resto</p>'
              }
            }
          }
        )

        post location_equipment_reports_path(location_equipment), params: params
        report = Report.last
        body = report.sections.find_by!(title: "Notas").text_section.body

        expect(body).to include("<strong>equipo</strong>")
        expect(body).to include("resto")
        expect(body).not_to include("<img")
        expect(body).not_to include("data:image")
        expect(body).not_to include("url(")

        get location_equipment_report_path(location_equipment, report)
        expect(response.body).to include("<strong>equipo</strong>")
        expect(response.body).not_to include("data:image")
        expect(response.body).not_to include('alt="foto"')
      end

      it "uploads images to the image section" do
        params = template_params.deep_merge(
          report: {
            section_inputs: {
              photos_section.id => {
                images: [fixture_file_upload(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg")]
              }
            }
          }
        )

        post location_equipment_reports_path(location_equipment), params: params
        expect(Report.last.sections.find_by!(title: "Fotos").image_section.images).to be_attached
      end

      it "uploads directly uploaded images to the image section" do
        blobs = Array.new(2) do |index|
          ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new("img-#{index}"),
            filename: "foto-#{index}.png",
            content_type: "image/png"
          )
        end
        params = template_params.deep_merge(
          report: {
            section_inputs: {
              photos_section.id => {images: blobs.map(&:signed_id)}
            }
          }
        )

        post location_equipment_reports_path(location_equipment), params: params
        report = Report.last
        images = report.sections.find_by!(title: "Fotos").image_section.images
        expect(images.blobs).to match_array(blobs)

        get location_equipment_report_path(location_equipment, report)
        expect(response.body).to include("foto-0.png", "foto-1.png")
      end

      it "auto-assigns the template to the location equipment" do
        request
        expect(location_equipment.reload.report_templates).to include(report_template)
      end
    end

    describe "signatures" do
      def create_signature(name:, user: nil)
        signature = Signature.new(name: name, title: "Cargo", user: user)
        signature.image.attach(io: StringIO.new("img"), filename: "sig.png", content_type: "image/png")
        signature.save!
        signature
      end

      let(:technician) { create(:technician) }
      let!(:shared_signature) { create_signature(name: "Firma compartida") }
      let!(:own_signature) { create_signature(name: "Firma del tecnico", user: technician) }
      let!(:other_signature) { create_signature(name: "Firma ajena", user: create(:technician)) }

      context "when the user is a technician" do
        before { sign_in technician }

        it "offers their signature and unowned signatures" do
          get new_location_equipment_report_path(location_equipment, report_mode: "template")

          expect(response.body).to include("Firma compartida")
          expect(response.body).to include("Firma del tecnico")
          expect(response.body).not_to include("Firma ajena")
        end

        it "assigns their signature and unowned signatures" do
          post location_equipment_reports_path(location_equipment), params: template_params.deep_merge(
            report: {signature_ids: [shared_signature.id, own_signature.id]}
          )

          expect(Report.last.signatures).to contain_exactly(shared_signature, own_signature)
        end

        it "rejects a signature that belongs to someone else" do
          params = template_params.deep_dup
          params[:report].delete(:images)
          params[:report][:signature_ids] = [shared_signature.id, other_signature.id]

          expect {
            post location_equipment_reports_path(location_equipment), params: params
          }.not_to change(Report, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("incluye una firma que no se puede usar")
        end
      end

      context "when the user is an admin" do
        it "offers only unowned signatures" do
          get new_location_equipment_report_path(location_equipment, report_mode: "template")

          expect(response.body).to include("Firma compartida")
          expect(response.body).not_to include("Firma del tecnico")
          expect(response.body).not_to include("Firma ajena")
        end

        it "rejects signatures that belong to a user" do
          params = template_params.deep_dup
          params[:report].delete(:images)
          params[:report][:signature_ids] = [shared_signature.id, own_signature.id]

          expect {
            post location_equipment_reports_path(location_equipment), params: params
          }.not_to change(Report, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("incluye una firma que no se puede usar")
        end

        it "keeps a signature already on the report" do
          template_report = create(:report, :template_based, location_equipment: location_equipment, report_template: report_template)
          template_report.signatures << own_signature

          patch location_equipment_report_path(location_equipment, template_report), params: {
            report: {
              date: Date.today,
              report_template_id: template_report.report_template_id,
              signature_ids: [own_signature.id, shared_signature.id]
            }
          }

          expect(template_report.reload.signatures).to contain_exactly(own_signature, shared_signature)
        end
      end
    end

    describe "PATCH /update" do
      let(:template_report) { create(:report, :template_based, location_equipment: location_equipment, report_template: report_template) }
      let(:measurement) { template_report.sections.find_by!(title: "Tensión L1") }
      let(:request) do
        patch location_equipment_report_path(location_equipment, template_report),
          params: {
            report: {
              date: Date.today,
              report_template_id: template_report.report_template_id,
              section_inputs: {
                measurement.id => {
                  cells: {"0_1" => {value: "230.0"}}
                }
              }
            }
          }
      end

      it "updates the template report" do
        request
        template_report.reload
        expect(template_report.sections.find_by!(title: "Tensión L1").table_section.cell_at(0, 1).value).to eq("230.0")
      end

      it "updates a checked list item" do
        list = template_report.sections.find_by!(title: "Protocolo").list_section
        item = list.list_items.find_by!(name: "Verificación de torque")

        patch location_equipment_report_path(location_equipment, template_report), params: {
          report: {
            date: Date.today,
            report_template_id: template_report.report_template_id,
            section_inputs: {
              list.section_id => {
                items: {item.id => {checked: "1"}}
              }
            }
          }
        }

        expect(item.reload).to be_checked
        expect(list.list_items.find_by!(name: "Limpieza general")).not_to be_checked
      end

      it "does not attach a PDF" do
        request
        expect(template_report.reload.pdf).not_to be_attached
      end

      it "keeps images added while editing" do
        photos = template_report.sections.find_by!(title: "Fotos")
        blobs = Array.new(2) do |index|
          ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new("edit-#{index}"),
            filename: "edicion-#{index}.png",
            content_type: "image/png"
          )
        end

        patch location_equipment_report_path(location_equipment, template_report), params: {
          report: {
            date: Date.today,
            report_template_id: template_report.report_template_id,
            section_inputs: {
              photos.id => {images: blobs.map(&:signed_id)}
            }
          }
        }

        images = photos.reload.image_section.images
        expect(images.blobs).to match_array(blobs)

        get location_equipment_report_path(location_equipment, template_report)
        expect(response.body).to include("edicion-0.png", "edicion-1.png")
      end
    end

    describe "GET /show" do
      let(:template_report) do
        create(:report, :template_based, location_equipment: location_equipment, report_template: report_template).tap do |report|
          report.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1).update!(value: "220.5")
          report.sections.find_by!(title: "Protocolo").list_section.list_items.find_by!(name: "Limpieza general").update!(checked: true)
        end
      end

      it "returns a successful response" do
        get location_equipment_report_path(location_equipment, template_report)
        expect(response).to have_http_status(:success)
      end

      it "shows the client name in the logo cell when the client has no avatar" do
        get location_equipment_report_path(location_equipment, template_report)

        expect(response.body).to include("template-report__client-name")
        expect(response.body).to include(location_equipment.client.name)
      end

      it "shows the client avatar when one is attached" do
        location_equipment.client.avatar.attach(
          Rack::Test::UploadedFile.new(Rails.root.join("app/assets/images/placeholder-img.jpeg"), "image/jpeg")
        )

        get location_equipment_report_path(location_equipment, template_report)

        expect(response.body).to include("template-report__logo--client")
        expect(response.body).not_to include("template-report__client-name")
      end
      
      it "prints the selected boolean option label" do
        cell = measurement_section.table_section.table_cells.find_by!(row_index: 0, column_index: 1)
        cell.update!(value_type: "boolean", for_metrics: false, fixed: false)
        cell.table_cell_options.find_by!(value: true).update!(label: "Aprobado")
        report = create(:report, :template_based, location_equipment: location_equipment, report_template: report_template)
        report.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1).update!(value: "1")

        get location_equipment_report_path(location_equipment, report)

        expect(response.body).to include("Aprobado")
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
        expect(response.body).to include("2.0 Información de localización")
        expect(response.body).to include(location_equipment.location.name)
        expect(response.body).to include("Tensión L1")
        expect(response.body).to include("Concepto")
        expect(response.body).to include("Fase")
        expect(response.body).to include("Línea 1")
        expect(response.body).to include("220.5")
        expect(response.body).to include("Notas")
        expect(response.body).to include("Imprimir / Guardar PDF")
      end

      it "renders checked and unchecked list items" do
        get location_equipment_report_path(location_equipment, template_report)
        expect(response.body).to include("Protocolo")
        expect(response.body).to include("Limpieza general")
        expect(response.body).to include("Verificación de torque")
        expect(response.body).to include("template-report__list-check--on")
        expect(response.body).not_to include("template-report__list-index")
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
