require "rails_helper"

RSpec.describe "/table_dropdowns", type: :request do
  let(:valid_attributes) do
    {
      name: "Estado general",
      table_dropdown_values_attributes: {
        "0" => {label: "Bueno", position: 0},
        "1" => {label: "Malo", position: 1}
      }
    }
  end
  let(:invalid_attributes) { {name: "", table_dropdown_values_attributes: {"0" => {label: ""}}} }
  let(:user) { create(:admin) }

  before { sign_in user }

  describe "GET /index" do
    it "redirects to the report templates tab" do
      get table_dropdowns_url
      expect(response).to redirect_to(report_templates_path(tab: "valores"))
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get table_dropdowns_url
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is a technician" do
      let(:user) { create(:technician) }

      it "opens the valores tab" do
        create(:table_dropdown, name: "Set visible")
        get table_dropdowns_url
        expect(response).to redirect_to(report_templates_path(tab: "valores"))
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include("Set visible")
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_table_dropdown_url
      expect(response).to be_successful
      expect(response.body).to include("Añadir valor")
    end

    it "keeps the cell origin so the new list returns to the template" do
      get new_table_dropdown_url, params: {from: "cell"}
      expect(response).to be_successful
      expect(response.body).to include('name="from"')
      expect(response.body).to include('value="cell"')
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get new_table_dropdown_url
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      table_dropdown = create(:table_dropdown, name: "Estado", values: ["Bueno"])
      get edit_table_dropdown_url(table_dropdown)
      expect(response).to be_successful
      expect(response.body).to include("Bueno")
    end
  end

  describe "POST /create" do
    it "creates a set and its values" do
      expect {
        post table_dropdowns_url, params: {table_dropdown: valid_attributes}
      }.to change(TableDropdown, :count).by(1)

      dropdown = TableDropdown.order(:id).last
      expect(dropdown.table_dropdown_values.order(:position).map(&:label)).to eq(["Bueno", "Malo"])
      expect(response).to redirect_to(report_templates_path(tab: "valores"))
    end

    it "appends the set via turbo stream" do
      post table_dropdowns_url, params: {table_dropdown: valid_attributes}, as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('turbo-stream action="append" target="table_dropdowns"')
    end

    it "returns the new set for the cell that opened the modal" do
      post table_dropdowns_url, params: {from: "cell", table_dropdown: valid_attributes}, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('target="dropdown_catalog_events"')
      expect(response.body).to include("dropdown-catalog-option")
      expect(response.body).to include("Estado general")
      expect(response.body).to include("Bueno, Malo")
      expect(response.body).not_to include('target="table_dropdowns"')
    end

    it "does not create a set with invalid parameters" do
      expect {
        post table_dropdowns_url, params: {table_dropdown: invalid_attributes}
      }.not_to change(TableDropdown, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "re-renders the form via turbo stream" do
      post table_dropdowns_url, params: {table_dropdown: invalid_attributes}, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('turbo-stream action="update" target="remote_modal_body"')
    end
  end

  describe "PATCH /update" do
    it "updates the name and values" do
      table_dropdown = create(:table_dropdown, name: "Estado", values: ["Bueno"])
      value = table_dropdown.table_dropdown_values.first

      patch table_dropdown_url(table_dropdown), params: {
        table_dropdown: {
          name: "Estado editado",
          table_dropdown_values_attributes: {
            "0" => {id: value.id, label: "Aceptable", position: 0},
            "1" => {label: "Rechazado", position: 1}
          }
        }
      }

      expect(response).to redirect_to(report_templates_path(tab: "valores"))
      expect(table_dropdown.reload.name).to eq("Estado editado")
      expect(table_dropdown.table_dropdown_values.order(:position).map(&:label)).to eq(["Aceptable", "Rechazado"])
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes an unused set" do
      table_dropdown = create(:table_dropdown)
      expect {
        delete table_dropdown_url(table_dropdown)
      }.to change(TableDropdown.kept, :count).by(-1)
      expect(table_dropdown.reload).to be_discarded
      expect(response).to redirect_to(report_templates_path(tab: "valores"))
    end

    it "keeps a set that a cell is using" do
      table_dropdown = create(:table_dropdown)
      template = create(:report_template, :with_measurements)
      cell = template.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1)
      cell.update!(value_type: "dropdown", fixed: false, for_metrics: false, table_dropdown: table_dropdown)

      expect {
        delete table_dropdown_url(table_dropdown)
      }.not_to change(TableDropdown.kept, :count)
      expect(table_dropdown.reload).not_to be_discarded
      expect(flash[:alert]).to include("celdas que lo usan")
    end
  end
end
