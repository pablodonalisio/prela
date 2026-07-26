require "rails_helper"

RSpec.describe "/report_templates", type: :request do
  let(:valid_attributes) do
    {
      name: "Preventivo UPS",
      measurements: {ReportTemplate.generate_field_key => {name: "Tensión L1", type: "float"}},
      report_template_tasks_attributes: {
        "0" => {name: "Limpieza general", position: 0}
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
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_report_template_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get new_report_template_url
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      report_template = create(:report_template, :with_measurements)
      get edit_report_template_url(report_template)
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        report_template = create(:report_template, :with_measurements)
        get edit_report_template_url(report_template)
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
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

      it "creates nested template tasks" do
        expect {
          post report_templates_url, params: {report_template: valid_attributes}
        }.to change(ReportTemplateTask, :count).by(1)
        expect(ReportTemplate.last.report_template_tasks.first.name).to eq("Limpieza general")
      end

      it "redirects to the report templates list" do
        post report_templates_url, params: {report_template: valid_attributes}
        expect(response).to redirect_to(report_templates_url)
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

      it "re-renders the form via turbo stream when name is missing" do
        post report_templates_url,
          params: {report_template: {name: "", measurements: {}}},
          as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('turbo-stream action="update" target="remote_modal_body"')
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
          room_specifications: {ReportTemplate.generate_field_key => {name: "Temperatura", type: "float"}}
        }
      end

      it "updates the requested report_template" do
        report_template = create(:report_template, :with_measurements)
        patch report_template_url(report_template), params: {report_template: new_attributes}
        report_template.reload
        expect(report_template.name).to eq "Preventivo tablero"
        expect(report_template.room_specifications.values.first["name"]).to eq "Temperatura"
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
