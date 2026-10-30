require "rails_helper"

RSpec.describe "EquipmentSupplies", type: :request do
  let(:location_equipment) { create(:location_equipment) }
  let(:supply) { create(:supply, name: "Aceite hidráulico ISO 68") }

  before { sign_in(create(:admin)) }

  describe "GET /new" do
    it "renders a searchable supply picker that omits supplies already assigned" do
      supply
      assigned = create(:supply, name: "BP5-12")
      create(:equipment_supply, location_equipment: location_equipment, supply: assigned)

      get new_equipment_supply_url, params: {equipment_supply: {location_equipment_id: location_equipment.id}}

      expect(response).to be_successful
      expect(response.body).to include("searchable-select")
      expect(response.body).to include("Tipo")
      expect(response.body).to include("Todos")
      expect(response.body).to include(%(data-kind-id="#{supply.supply_kind_id}"))
      expect(response.body).to include(">#{supply.name}</option>")
      expect(response.body).not_to include("#{supply.supply_kind.name} — #{supply.name}")
      expect(response.body).not_to include("BP5-12")
      expect(response.body).to include("Cantidad")
    end

    it "redirects technicians" do
      sign_in create(:technician)

      get new_equipment_supply_url, params: {equipment_supply: {location_equipment_id: location_equipment.id}}

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /edit" do
    let!(:equipment_supply) { create(:equipment_supply, location_equipment: location_equipment, supply: supply) }

    it "keeps the current supply in the picker" do
      other = create(:supply, name: "BP7-12")
      create(:equipment_supply, location_equipment: location_equipment, supply: other)

      get edit_equipment_supply_url(equipment_supply)

      expect(response).to be_successful
      expect(response.body).to include(supply.name)
      expect(response.body).to include(%(value="#{supply.supply_kind_id}" selected>#{supply.supply_kind.name}</option>))
      expect(response.body).not_to include("BP7-12")
    end
  end

  describe "POST /create" do
    let(:valid_attributes) { {location_equipment_id: location_equipment.id, supply_id: supply.id, quantity: 2} }

    it "creates a supply assignment and redirects to the location equipment" do
      expect {
        post equipment_supplies_url, params: {equipment_supply: valid_attributes}
      }.to change(EquipmentSupply, :count).by(1)

      expect(response).to redirect_to(location_equipment)
      expect(EquipmentSupply.last.quantity).to eq(2)
    end

    it "rerenders the supplies list via turbo stream" do
      post equipment_supplies_url, params: {equipment_supply: valid_attributes}, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(turbo-stream action="replace" target="supplies_location_equipment_#{location_equipment.id}"))
      expect(response.body).to include(supply.name)
      expect(response.body).to include(supply.supply_kind.name)
      expect(response.body).to include("Cantidad: 2")
    end

    it "renders the form again when the quantity is invalid" do
      post equipment_supplies_url, params: {equipment_supply: valid_attributes.merge(quantity: 0)}, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('turbo-stream action="update" target="remote_modal_body"')
    end
  end

  describe "PUT /update" do
    let!(:equipment_supply) { create(:equipment_supply, location_equipment: location_equipment, supply: supply, quantity: 1) }

    it "updates the quantity and redirects to the location equipment" do
      put equipment_supply_url(equipment_supply), params: {equipment_supply: {quantity: 4}}

      expect(equipment_supply.reload.quantity).to eq(4)
      expect(response).to redirect_to(location_equipment)
    end

    it "rerenders the supplies list via turbo stream" do
      put equipment_supply_url(equipment_supply), params: {equipment_supply: {quantity: 4}}, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(turbo-stream action="replace" target="supplies_location_equipment_#{location_equipment.id}"))
      expect(response.body).to include("Cantidad: 4")
    end
  end

  describe "DELETE /destroy" do
    let!(:equipment_supply) { create(:equipment_supply, location_equipment: location_equipment, supply: supply) }

    it "removes the assignment and redirects to the location equipment" do
      expect {
        delete equipment_supply_url(equipment_supply)
      }.to change(EquipmentSupply, :count).by(-1)

      expect(response).to redirect_to(location_equipment)
    end

    it "rerenders the supplies list via turbo stream" do
      delete equipment_supply_url(equipment_supply), as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(turbo-stream action="replace" target="supplies_location_equipment_#{location_equipment.id}"))
      expect(response.body).to include("No hay insumos todavía.")
    end
  end
end
