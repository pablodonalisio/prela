require "rails_helper"

RSpec.describe "/supplies", type: :request do
  let(:supply_kind) { create(:supply_kind, name: "Batería") }
  let(:valid_attributes) {
    {
      supply_kind_id: supply_kind.id,
      name: "BP5-12",
      description: "12 V, 7 Ah",
      reference_url: "https://example.com/bp5-12"
    }
  }
  let(:invalid_attributes) { {name: nil, reference_url: "nota"} }
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders kept supplies and the insumos tabs" do
      create(:supply, name: "BP5-12", supply_kind: supply_kind)
      create(:supply, name: "Descartada").discard!

      get supplies_url

      expect(response).to be_successful
      expect(response.body).to include("Lista")
      expect(response.body).to include("Tipos de Insumos")
      expect(response.body).to include("BP5-12")
      expect(response.body).to include("Foto de BP5-12")
      expect(response.body).to include("placeholder-img-")
      expect(response.body).not_to include("Descartada")
    end

    it "shows the attached avatar" do
      supply = create(:supply, name: "BP5-12", supply_kind: supply_kind)
      supply.avatar.attach(
        io: File.open(Rails.root.join("spec/test_files/placeholder-img.jpeg")),
        filename: "battery.jpeg",
        content_type: "image/jpeg"
      )

      get supplies_url

      expect(response.body).to include("Foto de BP5-12")
      expect(response.body).to include("battery.jpeg")
    end

    it "paginates the list" do
      (1..13).each { |number| create(:supply, name: format("Insumo %02d", number)) }

      get supplies_url

      expect(response.body).to include("Insumo 01")
      expect(response.body).not_to include("Insumo 13")
      expect(response.body).to include("Siguiente")
      expect(response.body).to include('data-turbo-action="advance"')

      get supplies_url, params: {page: 2}

      expect(response.body).to include("Insumo 13")
      expect(response.body).not_to include("Insumo 01")
    end

    it "searches by supply name" do
      create(:supply, name: "BP5-12", supply_kind: supply_kind)
      create(:supply, name: "Aceite 15W40", supply_kind: supply_kind)

      get supplies_url, params: {name: "aceite"}

      expect(response.body).to include("Aceite 15W40")
      expect(response.body).not_to include("BP5-12")
      expect(response.body).to include('value="aceite"')
    end

    it "shows an empty message when the name search has no matches" do
      create(:supply, name: "BP5-12", supply_kind: supply_kind)

      get supplies_url, params: {name: "zzz"}

      expect(response.body).to include("No hay insumos que coincidan con la búsqueda.")
      expect(response.body).not_to include("BP5-12")
    end

    it "filters by supply kind" do
      oil = create(:supply_kind, name: "Aceite")
      create(:supply, name: "BP5-12", supply_kind: supply_kind)
      create(:supply, name: "15W40", supply_kind: oil)

      get supplies_url, params: {supply_kind_ids: [oil.id]}

      expect(response.body).to include("15W40")
      expect(response.body).not_to include("BP5-12")
    end

    it "prepares the new supply modal when open=new" do
      get supplies_url, params: {open: "new"}

      expect(response).to be_successful
      expect(response.body).to include('data-controller="open-remote-modal"')
      expect(response.body).to include(%(data-open-remote-modal-url-value="#{new_supply_path}"))
    end

    context "when user is a technician" do
      let(:user) { create(:technician) }

      it "renders the list" do
        get supplies_url
        expect(response).to be_successful
      end
    end

    context "when user is not admin or technician" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get supplies_url
        expect(flash[:alert]).to eq "No estás autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_supply_url
      expect(response).to be_successful
    end

    it "links to create a supply kind" do
      get new_supply_url
      expect(response.body).to include("¿No encontrás el tipo de insumo?")
      expect(response.body).to include(supply_kinds_path(open: "new"))
    end

    it "renders a searchable replacement picker" do
      create(:supply, name: "Aceite hidráulico ISO 68")

      get new_supply_url

      expect(response.body).to include("Referencias cruzadas")
      expect(response.body).to include('data-dropdown-search-target="chips"')
      expect(response.body).to include("Filtrar por tipo")
      expect(response.body).to include("Todos")
      expect(response.body).to include("Aceite hidráulico ISO 68")
      expect(response.body).to include('name="supply[replacement_ids][]"')
    end

    context "when user is a technician" do
      let(:user) { create(:technician) }

      it "redirects to the root path" do
        get new_supply_url
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    it "creates a supply and its replacements" do
      equivalent = create(:supply)

      expect {
        post supplies_url, params: {supply: valid_attributes.merge(replacement_ids: [equivalent.id])}
      }.to change(Supply, :count).by(1)

      supply = Supply.order(:id).last
      expect(supply.replacement_supplies).to contain_exactly(equivalent)
      expect(response).to redirect_to(supplies_url)
    end

    it "rerenders the list via turbo stream" do
      post supplies_url, params: {supply: valid_attributes}, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('turbo-stream action="replace" target="supplies"')
      expect(response.body).to include("BP5-12")
    end

    it "keeps the current filter when rerendering the list" do
      oil = create(:supply_kind, name: "Aceite")
      create(:supply, name: "15W40", supply_kind: oil)

      post supplies_url,
        params: {supply: valid_attributes},
        headers: {"Referer" => supplies_url(supply_kind_ids: [oil.id])},
        as: :turbo_stream

      expect(response.body).to include("15W40")
      expect(response.body).not_to include("BP5-12")
    end

    it "keeps the name search when rerendering the list" do
      create(:supply, name: "Aceite 15W40", supply_kind: supply_kind)

      post supplies_url,
        params: {supply: valid_attributes},
        headers: {"Referer" => supplies_url(name: "aceite")},
        as: :turbo_stream

      expect(response.body).to include("Aceite 15W40")
      expect(response.body).not_to include("BP5-12")
    end

    it "does not create a supply with invalid parameters" do
      expect {
        post supplies_url, params: {supply: invalid_attributes}
      }.not_to change(Supply, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rerenders the form when a new supply with a photo is invalid" do
      avatar = fixture_file_upload(Rails.root.join("spec/test_files/placeholder-img.jpeg"), "image/jpeg")

      expect {
        post supplies_url,
             params: {supply: valid_attributes.merge(name: nil, avatar: avatar)},
             as: :turbo_stream
      }.not_to change(Supply, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Foto")
    end
  end

  describe "PATCH /update" do
    it "updates the requested supply" do
      supply = create(:supply, supply_kind: supply_kind)
      patch supply_url(supply), params: {supply: {name: "BP7-12", reference_url: "https://example.com/bp7"}}

      expect(supply.reload.name).to eq "BP7-12"
      expect(supply.reference_url).to eq "https://example.com/bp7"
      expect(response).to redirect_to(supplies_url)
    end

    it "clears replacements when none stay selected" do
      supply = create(:supply, supply_kind: supply_kind)
      other = create(:supply)
      supply.update!(replacement_ids: [other.id])

      patch supply_url(supply), params: {supply: {replacement_ids: [""]}}

      expect(supply.reload.replacement_supplies).to be_empty
    end

    it "rerenders the list via turbo stream" do
      supply = create(:supply, supply_kind: supply_kind, name: "BP5-12")

      patch supply_url(supply), params: {supply: {name: "BP7-12"}}, as: :turbo_stream

      expect(response.body).to include('turbo-stream action="replace" target="supplies"')
      expect(response.body).to include("BP7-12")
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes the requested supply" do
      supply = create(:supply)

      expect {
        delete supply_url(supply)
      }.to change(Supply.kept, :count).by(-1)
      expect(supply.reload).to be_discarded
      expect(response).to redirect_to(supplies_url)
    end

    it "rerenders the last available page via turbo stream" do
      supplies = (1..13).map { |number| create(:supply, name: format("Insumo %02d", number)) }

      delete supply_url(supplies.last),
        headers: {"Referer" => supplies_url(page: 2)},
        as: :turbo_stream

      expect(response).to be_successful
      expect(response.body).to include('turbo-stream action="replace" target="supplies"')
      expect(response.body).to include("Insumo 01")
      expect(response.body).not_to include("Insumo 13")
    end
  end
end
