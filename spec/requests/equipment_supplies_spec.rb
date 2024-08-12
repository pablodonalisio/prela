require "rails_helper"

RSpec.describe "EquipmentSupplies", type: :request do
  before { sign_in(create(:admin)) }

  describe "GET /new" do
    let(:equipment) { create(:equipment) }
    let(:params) { {equipment_supply: {equipmentable_id: equipment.id, equipmentable_type: "Equipment", suppliable_type: "Battery"}} }

    it "renders a successful response and responds with HTML" do
      get new_equipment_supply_url, params: params
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    let!(:equipment_supply) { create(:equipment_supply) }

    it "renders a successful response and responds with HTML" do
      get edit_equipment_supply_url(equipment_supply)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let(:equipment) { create(:equipment) }
    let(:supply) { create(:battery) }
    let(:valid_attributes) { {equipmentable_id: equipment.id, equipmentable_type: "Equipment", suppliable_type: "Battery", suppliable_id: supply.id} }

    context "with valid parameters" do
      it "creates a new EquipmentSupply and responds with HTML" do
        expect {
          post equipment_supplies_url, params: {equipment_supply: valid_attributes}
        }.to change(EquipmentSupply, :count).by(1)
        expect(response).to redirect_to(url_for(EquipmentSupply.last.equipmentable))
      end

      it "creates a new EquipmentSupply and responds with turbo_stream" do
        post equipment_supplies_url, params: {equipment_supply: valid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"append\" target=\"equipment_battery\"")
      end
    end
  end

  describe "PUT /update" do
    let!(:equipment_supply) { create(:equipment_supply) }
    let(:new_suppliable) { create(:battery) }
    let(:new_attributes) { {suppliable_id: new_suppliable.id} }

    it "updates the requested equipment supply and responds with HTML" do
      put equipment_supply_url(equipment_supply), params: {equipment_supply: new_attributes}
      equipment_supply.reload
      expect(equipment_supply.suppliable_id).to eq(new_suppliable.id)
      expect(response).to redirect_to(url_for(equipment_supply.equipmentable))
    end

    it "updates the requested equipment supply and responds with turbo_stream" do
      put equipment_supply_url(equipment_supply), params: {equipment_supply: new_attributes}, as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"replace\" target=\"equipment_supply_#{equipment_supply.id}\"")
    end
  end

  describe "DELETE /destroy" do
    let!(:equipment_supply) { create(:equipment_supply) }

    it "destroys the requested equipment supply and responds with HTML" do
      expect {
        delete equipment_supply_url(equipment_supply)
      }.to change(EquipmentSupply, :count).by(-1)
      expect(response).to redirect_to(url_for(equipment_supply.equipmentable))
    end

    it "destroys the requested equipment supply and responds with turbo_stream" do
      delete equipment_supply_url(equipment_supply), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"equipment_supply_#{equipment_supply.id}\"")
    end
  end
end
