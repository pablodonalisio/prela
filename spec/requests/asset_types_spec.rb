require "rails_helper"

RSpec.describe "/asset_types", type: :request do
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "POST /create" do
    it "creates a new asset type" do
      expect {
        post asset_types_url, params: {asset_type: {name: "Generador"}}
      }.to change(AssetType, :count).by(1)
    end

    it "redirects to the equipment kinds list" do
      post asset_types_url, params: {asset_type: {name: "Generador"}}
      expect(response).to redirect_to(equipment_kinds_url)
    end

    it "replaces the picker via turbo stream and selects the new type" do
      post asset_types_url, params: {asset_type: {name: "Generador"}}, as: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('turbo-stream action="replace" target="asset_type_picker"')
      expect(response.body).to include("Generador")
      expect(response.body).to include("El tipo de activo se creó correctamente.")
    end

    it "refreshes the filter dropdown and keeps the current selection" do
      selected = create(:asset_type, name: "Tablero")

      post asset_types_url,
        params: {asset_type: {name: "Generador"}, asset_type_ids: [selected.id]},
        as: :turbo_stream

      expect(response.body).to include('turbo-stream action="replace" target="equipment_kind_filters"')
      expect(response.body).to match(/value="#{selected.id}"[^>]*checked="checked"/)
      expect(response.body).to include("Generador")
      generator_id = AssetType.find_by!(name: "Generador").id
      expect(response.body).not_to match(/value="#{generator_id}"[^>]*checked="checked"/)
    end

    context "with invalid parameters" do
      it "does not create a duplicate type and shows the error in the menu" do
        create(:asset_type, name: "Tablero")

        expect {
          post asset_types_url, params: {asset_type: {name: "Tablero"}}, as: :turbo_stream
        }.not_to change(AssetType, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("ya ha sido tomado")
        expect(response.body).to include("Añadir nuevo tipo...")
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        post asset_types_url, params: {asset_type: {name: "Generador"}}
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /update" do
    it "renames the asset type via turbo stream" do
      asset_type = create(:asset_type, name: "Generador")

      patch asset_type_url(asset_type),
        params: {asset_type: {name: "Grupo"}, selected_id: asset_type.id},
        as: :turbo_stream

      expect(asset_type.reload.name).to eq("Grupo")
      expect(response.body).to include("Grupo")
      expect(response.body).to include("El tipo de activo se actualizó correctamente.")
    end

    it "shows a duplicate name error in the menu" do
      asset_type = create(:asset_type, name: "Generador")
      create(:asset_type, name: "Tablero")

      patch asset_type_url(asset_type),
        params: {asset_type: {name: "Tablero"}, selected_id: asset_type.id},
        as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(asset_type.reload.name).to eq("Generador")
      expect(response.body).to include("ya ha sido tomado")
    end

    it "redirects to the equipment kinds list" do
      asset_type = create(:asset_type, name: "Generador")
      patch asset_type_url(asset_type), params: {asset_type: {name: "Grupo"}}
      expect(response).to redirect_to(equipment_kinds_url)
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        asset_type = create(:asset_type, name: "Generador")
        patch asset_type_url(asset_type), params: {asset_type: {name: "Grupo"}}
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "drops a deleted type from the filter dropdown" do
      kept = create(:asset_type, name: "Tablero")
      asset_type = create(:asset_type, name: "Generador")

      delete asset_type_url(asset_type),
        params: {asset_type_ids: [kept.id, asset_type.id]},
        as: :turbo_stream

      expect(response.body).to match(/value="#{kept.id}"[^>]*checked="checked"/)
      expect(response.body).not_to include(%(value="#{asset_type.id}"))
      expect(response.body).not_to include("Generador")
    end

    it "soft-deletes a type that no equipment kind uses" do
      asset_type = create(:asset_type, name: "Generador")

      expect {
        delete asset_type_url(asset_type), as: :turbo_stream
      }.to change(AssetType.kept, :count).by(-1)

      expect(asset_type.reload).to be_discarded
      expect(response.body).to include("El tipo de activo se eliminó.")
    end

    it "does not delete a type assigned to an equipment kind" do
      asset_type = create(:asset_type, name: "a2")
      create(:equipment_kind, name: "a1", asset_type: asset_type)

      delete asset_type_url(asset_type), as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(asset_type.reload).not_to be_discarded
      expect(response.body).to include("No se puede eliminar porque hay otros equipos asociados.")
    end

    it "redirects to the equipment kinds list" do
      asset_type = create(:asset_type, name: "Generador")
      delete asset_type_url(asset_type)
      expect(response).to redirect_to(equipment_kinds_url)
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        asset_type = create(:asset_type, name: "Generador")
        delete asset_type_url(asset_type)
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
