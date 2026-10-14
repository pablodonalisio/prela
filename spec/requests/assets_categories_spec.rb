require "rails_helper"

RSpec.describe "/assets_categories", type: :request do
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "POST /create" do
    it "creates a new asset type" do
      expect {
        post assets_categories_url, params: {assets_category: {name: "Generador"}}
      }.to change(AssetsCategory, :count).by(1)
    end

    it "redirects to the equipment kinds list" do
      post assets_categories_url, params: {assets_category: {name: "Generador"}}
      expect(response).to redirect_to(equipment_kinds_url)
    end

    it "replaces the picker via turbo stream and selects the new type" do
      post assets_categories_url, params: {assets_category: {name: "Generador"}}, as: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('turbo-stream action="replace" target="assets_category_picker"')
      expect(response.body).to include("Generador")
      expect(response.body).to include("La categoría se creó correctamente.")
    end

    it "refreshes the filter dropdown and keeps the current selection" do
      selected = create(:assets_category, name: "Tablero")

      post assets_categories_url,
        params: {assets_category: {name: "Generador"}, assets_category_ids: [selected.id]},
        as: :turbo_stream

      expect(response.body).to include('turbo-stream action="replace" target="equipment_kind_filters"')
      expect(response.body).to match(/value="#{selected.id}"[^>]*checked="checked"/)
      expect(response.body).to include("Generador")
      generator_id = AssetsCategory.find_by!(name: "Generador").id
      expect(response.body).not_to match(/value="#{generator_id}"[^>]*checked="checked"/)
    end

    context "with invalid parameters" do
      it "does not create a duplicate type and shows the error in the menu" do
        create(:assets_category, name: "Tablero")

        expect {
          post assets_categories_url, params: {assets_category: {name: "Tablero"}}, as: :turbo_stream
        }.not_to change(AssetsCategory, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("ya ha sido tomado")
        expect(response.body).to include("Añadir nueva categoría...")
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        post assets_categories_url, params: {assets_category: {name: "Generador"}}
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /update" do
    it "renames the asset type via turbo stream" do
      assets_category = create(:assets_category, name: "Generador")

      patch assets_category_url(assets_category),
        params: {assets_category: {name: "Grupo"}, selected_id: assets_category.id},
        as: :turbo_stream

      expect(assets_category.reload.name).to eq("Grupo")
      expect(response.body).to include("Grupo")
      expect(response.body).to include("La categoría se actualizó correctamente.")
    end

    it "shows a duplicate name error in the menu" do
      assets_category = create(:assets_category, name: "Generador")
      create(:assets_category, name: "Tablero")

      patch assets_category_url(assets_category),
        params: {assets_category: {name: "Tablero"}, selected_id: assets_category.id},
        as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(assets_category.reload.name).to eq("Generador")
      expect(response.body).to include("ya ha sido tomado")
    end

    it "redirects to the equipment kinds list" do
      assets_category = create(:assets_category, name: "Generador")
      patch assets_category_url(assets_category), params: {assets_category: {name: "Grupo"}}
      expect(response).to redirect_to(equipment_kinds_url)
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        assets_category = create(:assets_category, name: "Generador")
        patch assets_category_url(assets_category), params: {assets_category: {name: "Grupo"}}
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "drops a deleted type from the filter dropdown" do
      kept = create(:assets_category, name: "Tablero")
      assets_category = create(:assets_category, name: "Generador")

      delete assets_category_url(assets_category),
        params: {assets_category_ids: [kept.id, assets_category.id]},
        as: :turbo_stream

      expect(response.body).to match(/value="#{kept.id}"[^>]*checked="checked"/)
      expect(response.body).not_to include(%(value="#{assets_category.id}"))
      expect(response.body).not_to include("Generador")
    end

    it "soft-deletes a type that no equipment kind uses" do
      assets_category = create(:assets_category, name: "Generador")

      expect {
        delete assets_category_url(assets_category), as: :turbo_stream
      }.to change(AssetsCategory.kept, :count).by(-1)

      expect(assets_category.reload).to be_discarded
      expect(response.body).to include("La categoría se eliminó.")
    end

    it "does not delete a type assigned to an equipment kind" do
      assets_category = create(:assets_category, name: "a2")
      create(:equipment_kind, name: "a1", assets_category: assets_category)

      delete assets_category_url(assets_category), as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(assets_category.reload).not_to be_discarded
      expect(response.body).to include("No se puede eliminar porque hay otros equipos asociados.")
    end

    it "redirects to the equipment kinds list" do
      assets_category = create(:assets_category, name: "Generador")
      delete assets_category_url(assets_category)
      expect(response).to redirect_to(equipment_kinds_url)
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        assets_category = create(:assets_category, name: "Generador")
        delete assets_category_url(assets_category)
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
