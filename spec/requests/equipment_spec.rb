require "rails_helper"

RSpec.describe "/equipments", type: :request do
  let(:valid_attributes) { {kind: "UPS", brand: "some brand", model: "some model"} }
  let(:invalid_attributes) { {kind: ""} }

  before { sign_in create(:user) }

  describe "GET /show" do
    let!(:equipment) { create(:equipment) }

    it "renders a successful response and responds with HTML" do
      get equipment_url(equipment)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response and responds with HTML" do
      get new_equipment_url
      expect(response).to be_successful
    end
  end

  describe "GET /index" do
    let!(:equipment) { create_list(:equipment, 3) }

    it "renders a successful response and responds with HTML" do
      get equipment_index_url
      expect(response).to be_successful
      expect(response.body).to include(equipment.first.model)
      expect(response.body).to include(equipment.second.model)
      expect(response.body).to include(equipment.third.model)
    end
  end

  describe "GET /edit" do
    let!(:equipment) { create(:equipment) }

    it "renders a successful response and responds with HTML" do
      get edit_equipment_url(equipment)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Equipment and responds with HTML" do
        post equipment_index_url, params: {equipment: valid_attributes}
        expect(response).to redirect_to(equipment_index_path)
      end

      it "creates a new Equipment and responds with turbo_stream" do
        post equipment_index_url, params: {equipment: valid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"append\" target=\"equipment\"")
      end
    end

    context "with invalid parameters" do
      context "when required parameters are missing" do
        it "does not create a new Equipment and responds with HTML" do
          post equipment_index_url, params: {equipment: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not create a new Equipment and responds with turbo_stream" do
          post equipment_index_url, params: {equipment: invalid_attributes}, as: :turbo_stream
          expect(response.media_type).to eq Mime[:turbo_stream]
          expect(response.body).to include("turbo-stream action=\"update\" target=\"remote_modal_body\"")
        end
      end

      context "when kind is not as expected" do
        let(:invalid_attributes) {
          {kind: "invalid kind", brand: "valid brand", model: "valid model"}
        }

        it "does not create a new Equipment and responds with HTML" do
          post equipment_index_url, params: {equipment: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "PATCH /update" do
    let(:equipment) { create(:equipment) }
    let(:new_attributes) { {model: "new model"} }

    context "with valid parameters" do
      it "updates the requested equipment and responds with HTML" do
        patch equipment_url(equipment), params: {equipment: new_attributes}
        equipment.reload
        expect(equipment.model).to eq("new model")
        expect(response).to redirect_to(equipment_index_path)
      end

      it "updates the requested equipment and responds with turbo_stream" do
        patch equipment_url(equipment), params: {equipment: new_attributes}, as: :turbo_stream
        equipment.reload
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"update\" target=\"equipment_#{equipment.id}\"")
      end
    end

    context "with invalid parameters" do
      it "does not update the equipment and responds with HTML" do
        patch equipment_url(equipment), params: {equipment: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the equipment and responds with turbo_stream" do
        patch equipment_url(equipment), params: {equipment: invalid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"update\" target=\"remote_modal_body\"")
      end
    end

    describe "DELETE /destroy" do
      let!(:equipment) { create(:equipment) }

      it "destroys the requested equipment and responds with HTML" do
        expect {
          delete equipment_url(equipment)
        }.to change(Equipment, :count).by(-1)
        expect(response).to redirect_to(equipment_index_url)
      end

      it "destroys the requested equipment and responds with turbo_stream" do
        delete equipment_url(equipment), as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"remove\" target=\"equipment_#{equipment.id}\"")
      end
    end
  end
end
