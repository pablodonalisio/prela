require "rails_helper"

RSpec.describe "/documents", type: :request do
  before { sign_in user }

  let(:user) { create(:admin) }
  let(:documentable) { create(:location_equipment) }

  describe "GET /new" do
    let(:params) do
      {
        document: {
          documentable_type: documentable.class.name,
          documentable_id: documentable.id
        }
      }
    end
    let(:request) { get new_polymorphic_path([documentable, :document]), params: params }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end

  describe "GET /edit" do
    let(:document) { create(:document, documentable: documentable) }
    let(:request) { get edit_polymorphic_path([documentable, document]) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end

  describe "GET /index" do
    let(:params) do
      {
        document: {
          documentable_type: documentable.class.name,
          documentable_id: documentable.id
        }
      }
    end

    it "returns a success response" do
      get polymorphic_path([documentable, :documents], params: params)
      expect(response).to redirect_to(documentable)
    end
  end

  describe "GET /show" do
    let(:document) { create(:document, documentable: documentable) }
    let(:request) { get polymorphic_path([documentable, document]) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let(:params) {
      {
        document: {
          description: "Test Document",
          file: fixture_file_upload("spec/fixtures/files/test.pdf", "application/pdf"),
          documentable_type: documentable.class.name,
          documentable_id: documentable.id
        }
      }
    }
    let(:request) { post polymorphic_path([documentable, :documents]), params: params }

    it "creates a new document" do
      expect {
        request
      }.to change(Document, :count).by(1)
    end

    it "redirects to the documentable show page" do
      request
      expect(response).to redirect_to(documentable)
      expect(flash[:notice]).to match(/El documento se creó correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { post polymorphic_path([documentable, :documents]), params: params }

      it "does not create a new document without a description" do
        params[:document][:description] = ""
        expect {
          request
        }.not_to change(Document, :count)
      end

      it "does not create a new document without a file" do
        params[:document][:file] = nil
        expect {
          request
        }.not_to change(Document, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        allow_any_instance_of(Document).to receive(:save).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:document) { create(:document, documentable: documentable) }
    let(:params) {
      {
        document: {
          description: "Updated Description"
        }
      }
    }
    let(:request) { patch polymorphic_path([documentable, document]), params: params }

    it "updates the requested document" do
      request
      document.reload
      expect(document.description).to eq("Updated Description")
    end

    it "redirects to the documentable page" do
      request
      expect(response).to redirect_to(polymorphic_path([documentable]))
      expect(flash[:notice]).to match(/El documento se edito correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { patch polymorphic_path([documentable, document]), params: params }

      it "does not update the document with invalid data" do
        params[:document][:description] = ""
        request
        document.reload
        expect(document.description).not_to eq("")
      end

      it "renders a successful response (i.e. to display the 'edit' template)" do
        allow_any_instance_of(Document).to receive(:update).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:document) { create(:document, documentable: documentable) }
    let(:request) { delete polymorphic_path([documentable, document]) }

    it "destroys the requested document" do
      expect {
        request
      }.to change(Document, :count).by(-1)
    end

    it "redirects to the documentable page" do
      request
      expect(response).to redirect_to(polymorphic_path([documentable]))
      expect(flash[:notice]).to match(/El documento ha sido eliminada./)
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end
end
