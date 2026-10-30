require "rails_helper"

RSpec.describe "/supply_kinds", type: :request do
  let(:valid_attributes) { {name: "Batería", description: "Baterías de UPS"} }
  let(:invalid_attributes) { {name: nil} }
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders kept kinds" do
      create(:supply_kind, name: "Batería")
      create(:supply_kind, name: "Viejo").discard!

      get supply_kinds_url

      expect(response).to be_successful
      expect(response.body).to include("Tipos de Insumos")
      expect(response.body).to include(%(href="#{supplies_path}"))
      expect(response.body).to include('data-turbo-action="advance"')
      expect(response.body).to include("Batería")
      expect(response.body).not_to include("Viejo")
    end

    it "prepares the new kind modal when open=new" do
      get supply_kinds_url, params: {open: "new"}

      expect(response.body).to include(%(data-open-remote-modal-url-value="#{new_supply_kind_path}"))
    end

    context "when user is not admin or technician" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get supply_kinds_url
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    it "creates a supply kind" do
      expect {
        post supply_kinds_url, params: {supply_kind: valid_attributes}
      }.to change(SupplyKind, :count).by(1)
      expect(SupplyKind.order(:id).last.description).to eq "Baterías de UPS"
      expect(response).to redirect_to(supply_kinds_url)
    end

    it "appends the kind via turbo stream" do
      post supply_kinds_url, params: {supply_kind: valid_attributes}, as: :turbo_stream

      expect(response.body).to include('turbo-stream action="append" target="supply_kinds"')
    end

    it "does not create a kind with invalid parameters" do
      expect {
        post supply_kinds_url, params: {supply_kind: invalid_attributes}
      }.not_to change(SupplyKind, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /update" do
    it "updates the requested kind" do
      supply_kind = create(:supply_kind, name: "Aceite")
      patch supply_kind_url(supply_kind), params: {supply_kind: {name: "Lubricante", description: "Aceites de motor"}}

      expect(supply_kind.reload.name).to eq "Lubricante"
      expect(supply_kind.description).to eq "Aceites de motor"
      expect(response).to redirect_to(supply_kinds_url)
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes a kind that has no kept supplies" do
      supply_kind = create(:supply_kind)

      expect {
        delete supply_kind_url(supply_kind)
      }.to change(SupplyKind.kept, :count).by(-1)
      expect(supply_kind.reload).to be_discarded
    end

    it "does not delete a kind that still has supplies" do
      supply_kind = create(:supply_kind)
      create(:supply, supply_kind: supply_kind)

      expect {
        delete supply_kind_url(supply_kind)
      }.not_to change(SupplyKind.kept, :count)
      expect(response).to redirect_to(supply_kinds_url)
      expect(flash[:alert]).to eq "No se puede eliminar el tipo porque tiene insumos."
    end

    it "keeps the kind in the list when turbo stream discard is rejected" do
      supply_kind = create(:supply_kind)
      create(:supply, supply_kind: supply_kind)

      delete supply_kind_url(supply_kind), as: :turbo_stream

      expect(response.body).not_to include("turbo-stream action=\"remove\"")
      expect(supply_kind.reload).not_to be_discarded
    end
  end
end
