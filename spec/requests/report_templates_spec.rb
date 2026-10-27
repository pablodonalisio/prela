require "rails_helper"

RSpec.describe "/report_templates", type: :request do
  let(:valid_attributes) do
    {
      name: "Preventivo UPS",
      sections_attributes: {
        "0" => {
          title: "Notas",
          position: 0,
          kind: "text",
          text_section_attributes: {body: "Detalle"}
        }
      }
    }
  end

  let(:invalid_attributes) do
    {name: nil}
  end

  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      create(:report_template, :with_measurements)
      get report_templates_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get report_templates_url
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_report_template_url
      expect(response).to be_successful
      expect(response.body).to include("El texto se carga al generar el informe.")
      expect(response.body).to include("Las imágenes se cargan al generar el informe.")
      expect(response.body).to include('readonly')
      expect(response.body).to include('type="file"')
      expect(response.body).not_to include("text_section")
      expect(response.body).not_to include("image_section")
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get new_report_template_url
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      report_template = create(:report_template, :with_measurements)
      get edit_report_template_url(report_template)
      expect(response).to be_successful
      expect(response.body).to include("Editar plantilla de informe")
      expect(response.body).not_to include("Texto base")
      expect(response.body).to include('placeholder="Título"')
      expect(response.body).to include('value="Concepto"')
      expect(response.body).to include('placeholder="Encabezado"')
      expect(response.body).to include('placeholder="Fila"')
      expect(response.body).to include('value="Fase"')
      expect(response.body).to include('value="L1"')
      expect(response.body).to include('data-value-wrap class="mb-3 hidden"')
      expect(response.body).to include('type="radio"')
      expect(response.body).to include(%(data-table-grid-max-rows-value="#{TableSection::MAX_ROWS}"))
      expect(response.body).to include(%(data-table-grid-max-columns-value="#{TableSection::MAX_COLUMNS}"))
      expect(response.body).to include(%(max="#{TableSection::MAX_ROWS}"))
      expect(response.body).to include(%(max="#{TableSection::MAX_COLUMNS}"))
    end

    it "renders boolean option inputs only for a boolean cell" do
      report_template = create(:report_template, :with_measurements)
      section = report_template.sections.find_by!(title: "Tensión L1")
      table = section.table_section
      cell = table.table_cells.find_by!(row_index: 0, column_index: 1)
      cell.update!(value_type: "boolean", for_metrics: false, fixed: false)
      cell.table_cell_options.find_by!(value: true).update!(label: "Aprobado")
      cell.table_cell_options.find_by!(value: false).update!(label: "Rechazado")

      get edit_report_template_url(report_template)

      expect(response.body).to include("Verdadero")
      expect(response.body).to include("Falso")
      expect(response.body).to include('value="Aprobado"')
      expect(response.body).to include('value="Rechazado"')
      expect(response.body).to include('data-boolean-options class="mb-3 mt-2 space-y-2 "')
      expect(response.body).to include('data-boolean-options class="mb-3 mt-2 space-y-2 hidden" disabled')
    end

    it "renders the invalid cell message" do
      report_template = create(:report_template, :with_measurements)
      section = report_template.sections.find_by!(title: "Tensión L1")
      table = section.table_section
      cell = table.table_cells.find_by!(row_index: 0, column_index: 0)

      patch report_template_url(report_template), params: {
        report_template: {
          sections_attributes: {
            "0" => {
              id: section.id,
              title: section.title,
              position: section.position,
              kind: section.kind,
              table_section_attributes: {
                id: table.id,
                row_count: table.row_count,
                column_count: table.column_count,
                table_cells_attributes: {
                  "0" => {
                    id: cell.id,
                    row_index: 0,
                    column_index: 0,
                    value_type: "float",
                    value: "no-es-numero",
                    fixed: "1"
                  }
                }
              }
            }
          }
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("no es válido")
      expect(response.body).to include('data-value-wrap class="mb-3"')
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        report_template = create(:report_template, :with_measurements)
        get edit_report_template_url(report_template)
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new ReportTemplate" do
        expect {
          post report_templates_url, params: {report_template: valid_attributes}
        }.to change(ReportTemplate, :count).by(1)
      end

      it "creates a list section with items in the given order" do
        post report_templates_url, params: {
          report_template: {
            name: "Protocolo UPS",
            sections_attributes: {
              "0" => {
                title: "Protocolo",
                position: 0,
                kind: "list",
                list_section_attributes: {
                  list_items_attributes: {
                    "0" => {name: "Limpieza general", position: 0},
                    "1" => {name: "Verificación de torque", position: 1}
                  }
                }
              }
            }
          }
        }

        section = ReportTemplate.last.sections.find_by!(title: "Protocolo")
        expect(section).to be_list
        expect(section.list_section.list_items.order(:position).map(&:name)).to eq(
          ["Limpieza general", "Verificación de torque"]
        )
      end

      it "redirects to the report templates list" do
        post report_templates_url, params: {report_template: valid_attributes}
        expect(response).to redirect_to(report_templates_url)
      end

      it "saves boolean option labels submitted with numeric indexes" do
        post report_templates_url, params: {
          report_template: {
            name: "Estados",
            sections_attributes: {
              "0" => {
                title: "Resultado",
                position: 0,
                kind: "table",
                table_section_attributes: {
                  row_count: 1,
                  column_count: 1,
                  table_labels_attributes: {
                    "0" => {axis: "column", position: 0, label: "Estado"},
                    "1" => {axis: "row", position: 0, label: "Resultado"}
                  },
                  table_cells_attributes: {
                    "0" => {
                      row_index: 0,
                      column_index: 0,
                      value_type: "boolean",
                      table_cell_options_attributes: {
                        "1" => {value: "true", label: "Aprobado"},
                        "0" => {value: "false", label: "Rechazado"}
                      }
                    }
                  }
                }
              }
            }
          }
        }

        cell = ReportTemplate.find_by!(name: "Estados").sections.first.table_section.table_cells.first
        expect(cell.option_label(true)).to eq("Aprobado")
        expect(cell.option_label(false)).to eq("Rechazado")
      end
    end

    context "with invalid parameters" do
      it "does not create a new ReportTemplate" do
        expect {
          post report_templates_url, params: {report_template: invalid_attributes}
        }.to change(ReportTemplate, :count).by(0)
      end

      it "renders a response with 422 status" do
        post report_templates_url, params: {report_template: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the full page form when name is missing" do
        post report_templates_url, params: {report_template: {name: ""}}

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Nueva plantilla de informe")
        expect(response.body).not_to include("remote_modal_body")
      end

      it "does not create a template when a table header is blank" do
        expect {
          post report_templates_url, params: {
            report_template: {
              name: "Sin encabezados",
              sections_attributes: {
                "0" => {
                  title: "Tabla",
                  position: 0,
                  kind: "table",
                  table_section_attributes: {
                    row_count: 1,
                    column_count: 1,
                    table_labels_attributes: {
                      "0" => {axis: "column", position: 0, label: ""},
                      "1" => {axis: "row", position: 0, label: "Fila 1"}
                    }
                  }
                }
              }
            }
          }
        }.not_to change(ReportTemplate, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Todos los encabezados de filas y columnas deben tener título.")
      end

      it "does not create a template when a section has no title" do
        expect {
          post report_templates_url, params: {
            report_template: {
              name: "Sin título",
              sections_attributes: {
                "0" => {title: "", position: 0, kind: "text"}
              }
            }
          }
        }.not_to change(ReportTemplate, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("no puede estar en blanco")
      end

      it "does not persist text entered on a template section" do
        post report_templates_url, params: {report_template: valid_attributes}

        section = ReportTemplate.last.sections.find_by!(title: "Notas")
        expect(section.text_section.body).to be_blank
      end

      it "does not create a duplicate report template" do
        create(:report_template, name: "Preventivo UPS")
        expect {
          post report_templates_url, params: {report_template: valid_attributes}
        }.not_to change(ReportTemplate, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          name: "Preventivo tablero",
          sections_attributes: {
            "0" => {
              title: "Temperatura",
              position: 0,
              kind: "text",
              text_section_attributes: {body: "Sala"}
            }
          }
        }
      end

      it "updates the requested report_template" do
        report_template = create(:report_template, :with_measurements)
        patch report_template_url(report_template), params: {report_template: new_attributes}
        report_template.reload
        expect(report_template.name).to eq "Preventivo tablero"
        expect(report_template.sections.map(&:title)).to include("Temperatura")
      end

      it "redirects to the report templates list" do
        report_template = create(:report_template, :with_measurements)
        patch report_template_url(report_template), params: {report_template: new_attributes}
        expect(response).to redirect_to(report_templates_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        report_template = create(:report_template, :with_measurements)
        patch report_template_url(report_template), params: {report_template: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested report_template" do
      report_template = create(:report_template, :with_measurements)
      expect {
        delete report_template_url(report_template)
      }.to change(ReportTemplate, :count).by(-1)
    end

    it "redirects to the report templates list" do
      report_template = create(:report_template, :with_measurements)
      delete report_template_url(report_template)
      expect(response).to redirect_to(report_templates_url)
    end
  end
end
