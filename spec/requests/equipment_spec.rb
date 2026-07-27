require "rails_helper"

RSpec.describe "/equipments", type: :request do
  let!(:ups_equipment_kind) { create(:equipment_kind, :ups) }
  let(:valid_attributes) do
    {
      equipment_kind_id: ups_equipment_kind.id,
      name: "some brand - some model",
      brand: "some brand",
      model: "some model",
      field_values: {
        "more_info" => "some info"
      }
    }
  end
  let(:invalid_attributes) { {name: ""} }

  before { sign_in create(:admin) }

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
      expect(response.body).to include(equipment.first.name)
      expect(response.body).to include(equipment.second.name)
      expect(response.body).to include(equipment.third.name)
    end

    context "with more than 10 records" do
      let!(:equipment) { create_list(:equipment, 11) }

      it "paginates results 10 per page" do
        get equipment_index_url
        expect(response).to be_successful
        expect(response.body.scan(/id="equipment_\d+"/).size).to eq(10)
        expect(response.body).to include("page=2")

        get equipment_index_url, params: {page: 2}
        expect(response).to be_successful
        expect(response.body.scan(/id="equipment_\d+"/).size).to eq(1)
      end
    end
  end

  describe "GET /edit" do
    let!(:equipment) { create(:equipment) }

    it "renders a successful response and responds with HTML" do
      get edit_equipment_url(equipment)
      expect(response).to be_successful
    end
  end

  describe "GET /field_inputs" do
    it "renders dynamic field inputs for the selected equipment kind" do
      get field_inputs_equipment_index_path(equipment_kind_id: ups_equipment_kind.id)
      expect(response).to be_successful
      expect(response.body).to include("Kva")
    end
  end

  describe "POST /create" do
    context "when creating a Ups Equipment with valid parameters" do
      it "creates a new Equipment and responds with HTML" do
        post equipment_index_url, params: {equipment: valid_attributes}
        expect(Equipment.last.field_values["more_info"]).to eq("some info")
        expect(response).to redirect_to(equipment_index_path)
      end

      it "creates a new Equipment and responds with turbo_stream" do
        post equipment_index_url, params: {equipment: valid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"append\" target=\"equipment\"")
      end
    end

    context "when creating a Power Unit Equipment with valid parameters" do
      let!(:power_unit_equipment_kind) do
        create(:equipment_kind,
          legacy_kind: "power_unit",
          name: "Grupo Electrógeno",
          generic_fields: {
            "motor_brand" => {"name" => "Marca del Motor", "type" => "string"},
            "motor_model" => {"name" => "Modelo del Motor", "type" => "string"},
            "generator_brand" => {"name" => "Marca del Generador", "type" => "string"},
            "generator_model" => {"name" => "Modelo del Generador", "type" => "string"},
            "kva" => {"name" => "Kva", "type" => "float"},
            "more_info" => {"name" => "Mas Info", "type" => "string"},
            "manual" => {"name" => "Manual", "type" => "string"}
          })
      end
      let(:valid_attributes) do
        {
          equipment_kind_id: power_unit_equipment_kind.id,
          name: "some brand - some model",
          brand: "some brand",
          model: "some model",
          field_values: {
            "more_info" => "some info",
            "motor_brand" => "some motor brand",
            "motor_model" => "some motor model",
            "generator_brand" => "some generator brand",
            "generator_model" => "some generator model",
            "kva" => "10"
          }
        }
      end

      it "creates a new Power Unit Equipment" do
        expect { post equipment_index_url, params: {equipment: valid_attributes} }.to change(Equipment, :count).by(1)
        equipment = Equipment.last
        expect(equipment.legacy_kind).to eq("power_unit")
        expect(equipment.brand).to eq("some brand")
        expect(equipment.model).to eq("some model")
        expect(equipment.field_values["motor_brand"]).to eq("some motor brand")
        expect(equipment.field_values["kva"]).to eq("10")
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
    end
  end

  describe "PATCH /update" do
    let(:equipment) { create(:equipment) }
    let(:new_attributes) { {name: "updated name"} }

    context "with valid parameters" do
      it "updates the requested equipment and responds with HTML" do
        patch equipment_url(equipment), params: {equipment: new_attributes}
        equipment.reload
        expect(equipment.name).to eq("updated name")
        expect(response).to redirect_to(equipment_index_path)
      end

      it "updates the requested equipment and responds with turbo_stream" do
        patch equipment_url(equipment), params: {equipment: new_attributes}, as: :turbo_stream
        equipment.reload
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"update\" target=\"equipment_#{equipment.id}\"")
      end
    end

    context "with field_values" do
      it "updates field_values on the equipment" do
        patch equipment_url(equipment),
          params: {equipment: {field_values: {"more_info" => "updated info"}}}
        equipment.reload
        expect(equipment.field_values["more_info"]).to eq("updated info")
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

      it "soft-deletes the requested equipment and responds with HTML" do
        expect {
          delete equipment_url(equipment)
        }.to change(Equipment.kept, :count).by(-1)
        expect(equipment.reload).to be_discarded
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
