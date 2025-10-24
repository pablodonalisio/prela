require "rails_helper"

RSpec.describe "Failures", type: :request do
  before { sign_in user }

  let(:user) { create(:admin) }
  let(:location_equipment) { create(:location_equipment) }

  describe "GET /new" do
    let(:request) { get new_location_equipment_failure_path(location_equipment) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    it "should instantiate a new failure" do
      request
      doc = Nokogiri::HTML(response.body)
      expect(doc.css('form input[name^="failure["]').any?).to be true
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
    let(:failure) { create(:failure, location_equipment: location_equipment) }
    let(:request) { get edit_location_equipment_failure_path(location_equipment, failure) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    it "should instantiate the existing failure" do
      request
      doc = Nokogiri::HTML(response.body)
      expect(doc.css('form input[name^="failure["][value="' + failure.description + '"]').any?).to be true
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
    it "returns a success response" do
      get location_equipment_failures_path(location_equipment)
      expect(response).to redirect_to(location_equipment_path(location_equipment))
    end
  end

  describe "POST /create" do
    let(:params) {
      {
        failure: {
          description: "Test Failure",
          date: Date.today
        }
      }
    }
    let(:request) { post location_equipment_failures_path(location_equipment), params: params }

    it "creates a new failure" do
      expect {
        request
      }.to change(Failure, :count).by(1)
    end

    it "redirects to the location_equipment show page" do
      request
      expect(response).to redirect_to(location_equipment)
      expect(flash[:notice]).to match(/El fallo se creó correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { post location_equipment_failures_path(location_equipment), params: params }

      it "does not create a new failure without a description" do
        params[:failure][:description] = ""
        expect {
          request
        }.not_to change(Failure, :count)
      end

      it "does not create a new failure without a date" do
        params[:failure][:date] = nil
        expect {
          request
        }.not_to change(Failure, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        allow_any_instance_of(Failure).to receive(:save).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:failure) { create(:failure, location_equipment: location_equipment) }
    let(:params) {
      {
        failure: {
          description: "Updated Description"
        }
      }
    }
    let(:request) { patch location_equipment_failure_path(location_equipment, failure), params: params }

    it "updates the requested failure" do
      request
      failure.reload
      expect(failure.description).to eq("Updated Description")
    end

    it "redirects to the location_equipment page" do
      request
      expect(response).to redirect_to(location_equipment_path(location_equipment))
      expect(flash[:notice]).to match(/El fallo se edito correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { patch location_equipment_failure_path(location_equipment, failure), params: params }

      it "does not update the failure with invalid data" do
        params[:failure][:description] = ""
        request
        failure.reload
        expect(failure.description).not_to eq("")
      end

      it "renders a successful response (i.e. to display the 'edit' template)" do
        allow_any_instance_of(Failure).to receive(:update).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:failure) { create(:failure, location_equipment: location_equipment) }
    let(:request) { delete location_equipment_failure_path(location_equipment, failure) }

    it "destroys the requested failure" do
      expect {
        request
      }.to change(Failure, :count).by(-1)
    end

    it "redirects to the location_equipment page" do
      request
      expect(response).to redirect_to(location_equipment_path(location_equipment))
      expect(flash[:notice]).to match(/El fallo ha sido eliminada./)
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
