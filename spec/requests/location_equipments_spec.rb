require "rails_helper"

RSpec.describe "/location_equipments", type: :request do
  before { sign_in create(:user) }

  describe "GET /new" do
    let(:client) { create(:client) }

    it "renders a successful response and responds with HTML" do
      get new_location_equipment_url, params: {client_id: client.id}
      expect(response).to be_successful
    end
  end

  describe "GET /index" do
    let!(:location_equipments) { create_list(:location_equipment, 3) }

    it "renders a successful response and responds with HTML" do
      get location_equipments_url
      expect(response).to be_successful
      location_equipments.each do |location_equipment|
        expect(response.body).to include(location_equipment.zone)
      end
    end

    context "with filter params" do
      it "filter by client" do
        get location_equipments_url, params: {client_ids: [location_equipments.first.location.client_id]}
        expect(response.body).to match("location_equipment_" + location_equipments.first.id.to_s)
        expect(response.body).not_to match("location_equipment_" + location_equipments.last.id.to_s)
      end

      it "filter by client and location" do
        location_equipments.last.location.client = location_equipments.first.client
        location_equipments.last.save
        params = {location_ids: [location_equipments.first.location_id], client_ids: [location_equipments.first.location.client_id]}
        get location_equipments_url, params: params
        expect(response.body).to match("location_equipment_" + location_equipments.first.id.to_s)
        expect(response.body).not_to match("location_equipment_" + location_equipments.last.id.to_s)
      end
    end
  end

  describe "GET /show" do
    let!(:location_equipment) { create(:location_equipment) }

    it "renders a successful response and responds with HTML" do
      get location_equipment_url(location_equipment)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    let!(:location_equipment) { create(:location_equipment) }

    it "renders a successful response and responds with HTML" do
      get edit_location_equipment_url(location_equipment)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let(:equipment) { create(:equipment) }
    let(:location) { create(:location) }
    let(:valid_attributes) { {equipment_id: equipment.id, location_id: location.id} }
    let(:invalid_attributes) { {equipment_id: ""} }

    context "with valid parameters" do
      it "creates a new LocationEquipment and responds with HTML" do
        expect {
          post location_equipments_url, params: {location_equipment: valid_attributes}
        }.to change(LocationEquipment, :count).by(1)
        expect(response).to redirect_to(location_equipments_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new LocationEquipment and responds with HTML" do
        expect {
          post location_equipments_url, params: {location_equipment: invalid_attributes}
        }.to change(LocationEquipment, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /update" do
    let!(:location_equipment) { create(:location_equipment) }
    let(:new_attributes) { {zone: "new zone"} }

    it "updates the requested location equipment and responds with HTML" do
      put location_equipment_url(location_equipment), params: {location_equipment: new_attributes}
      location_equipment.reload
      expect(location_equipment.zone).to eq("new zone")
      expect(response).to redirect_to(location_equipments_url)
    end

    it "updates the requested location equipment and responds with turbo_stream" do
      put location_equipment_url(location_equipment), params: {location_equipment: new_attributes}, as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"replace\" target=\"location_equipment_#{location_equipment.id}\"")
    end
  end

  describe "DELETE /destroy" do
    let!(:location_equipment) { create(:location_equipment) }

    it "destroys the requested location equipment and responds with HTML" do
      expect {
        delete location_equipment_url(location_equipment)
      }.to change(LocationEquipment, :count).by(-1)
      expect(response).to redirect_to(location_equipments_url)
    end

    it "destroys the requested location equipment and responds with turbo_stream" do
      delete location_equipment_url(location_equipment), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"location_equipment_#{location_equipment.id}\"")
    end
  end
end
