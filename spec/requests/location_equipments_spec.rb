require "rails_helper"

RSpec.describe "/location_equipments", type: :request do
  before { sign_in create(:admin) }

  describe "GET /new" do
    it "renders a successful response with the single-step form" do
      get new_location_equipment_url
      expect(response).to be_successful
      expect(response.body).to include("Cliente")
      expect(response.body).to include("Sala")
      expect(response.body).to include("Piso")
      expect(response.body).to include("Condición")
      expect(response.body).to include("Detalles")
      expect(response.body).to include("Aceptar")
    end
  end

  describe "GET /location_inputs" do
    let(:client) { create(:client) }

    it "returns a turbo frame with locations for the given client" do
      location = create(:location, client: client)
      get location_inputs_location_equipments_url, params: {client_id: client.id}
      expect(response).to be_successful
      expect(response.body).to include("le_location_inputs")
      expect(response.body).to include(location.name)
    end

    it "returns an empty turbo frame when client is not found" do
      get location_inputs_location_equipments_url, params: {client_id: 0}
      expect(response).to be_successful
      expect(response.body).to include("le_location_inputs")
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

      it "filter by status" do
        location_equipments.last.update(status: LocationEquipment.statuses.keys[1])
        get location_equipments_url, params: {status: LocationEquipment.statuses.keys[0]}
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
    let(:invalid_attributes) { {equipment_id: "", location_id: ""} }

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

      it "renders the new template with step 2 and responds with HTML" do
        post location_equipments_url, params: {location_equipment: invalid_attributes}
        expect(response.body).to include("Sede")
        expect(response.body).to include("Sala")
        expect(response.body).to include("Piso")
        expect(response.body).to include("Condición")
        expect(response.body).to include("Detalles")
        expect(response.body).to include("Aceptar")
      end
    end
  end

  describe "GET /field_inputs" do
    let(:equipment) { create(:equipment) }

    it "renders a turbo frame with specific_fields inputs for the equipment's kind" do
      get field_inputs_location_equipments_url, params: {equipment_id: equipment.id}
      expect(response).to be_successful
      expect(response.body).to include("turbo-frame")
      expect(response.body).to include("le_field_inputs")
    end

    it "returns an empty turbo frame when equipment is not found" do
      get field_inputs_location_equipments_url, params: {equipment_id: 0}
      expect(response).to be_successful
      expect(response.body).to include("le_field_inputs")
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

  describe "PUT /update field_values" do
    let!(:location_equipment) { create(:location_equipment) }

    it "updates field_values on the location equipment" do
      put location_equipment_url(location_equipment),
        params: {location_equipment: {field_values: {"Número de serie" => "SN-999"}}}
      location_equipment.reload
      expect(location_equipment.field_values["Número de serie"]).to eq("SN-999")
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
