require "rails_helper"

RSpec.describe "/contracts", type: :request do
  let(:client) { create(:client) }
  let(:file) { fixture_file_upload("spec/fixtures/files/test.pdf", "application/pdf") }
  let(:image) { fixture_file_upload("spec/test_files/placeholder-img.jpeg", "image/jpeg") }
  let(:valid_attributes) {
    {name: "Contrato 2026", starts_on: Date.current, ends_on: 1.year.from_now.to_date, files: [file, image]}
  }
  let(:invalid_attributes) {
    {name: "", starts_on: "", ends_on: "", files: []}
  }
  let(:contract) { create(:contract, client:) }

  before { sign_in create(:admin) }

  describe "GET /index" do
    it "renders the contracts table" do
      contract
      get client_contracts_url(client)

      expect(response).to be_successful
      expect(response.body).to include(contract.name)
      expect(response.body).to include("Fecha de inicio")
      expect(response.body).to include("Acciones")
      expect(response.body).to include("test.pdf")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_client_contract_url(client)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_client_contract_url(client, contract)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Contract with the uploaded file" do
        expect {
          post client_contracts_url(client), params: {contract: valid_attributes}
        }.to change(Contract, :count).by(1)

        created = Contract.order(:id).last
        expect(created.files.map { |attached| attached.filename.to_s }).to contain_exactly("test.pdf", "placeholder-img.jpeg")
        expect(created.name).to eq("Contrato 2026")
        expect(created.starts_on).to eq(Date.current)
        expect(created.ends_on).to eq(1.year.from_now.to_date)
      end

      it "redirects to the client" do
        post client_contracts_url(client), params: {contract: valid_attributes}
        expect(response).to redirect_to(client_path(client))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Contract" do
        expect {
          post client_contracts_url(client), params: {contract: invalid_attributes}
        }.not_to change(Contract, :count)
      end

      it "renders a response with 422 status" do
        post client_contracts_url(client), params: {contract: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders a response with 422 status when the end date is before the start date" do
        post client_contracts_url(client),
          params: {contract: valid_attributes.merge(starts_on: Date.current, ends_on: Date.yesterday)}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {name: "Contrato renovado", starts_on: Date.new(2024, 1, 1), ends_on: Date.new(2025, 1, 1)}
      }

      it "updates the requested contract" do
        patch client_contract_url(client, contract), params: {contract: new_attributes}
        contract.reload
        expect(contract.name).to eq("Contrato renovado")
        expect(contract.starts_on).to eq(Date.new(2024, 1, 1))
        expect(contract.ends_on).to eq(Date.new(2025, 1, 1))
      end

      it "redirects to the client" do
        patch client_contract_url(client, contract), params: {contract: new_attributes}
        expect(response).to redirect_to(client_url(client))
      end

      it "removes a file and rerenders the row" do
        contract.files.attach(image)
        removed = contract.files.blobs.find_by!(filename: "test.pdf")

        patch client_contract_url(client, contract),
          params: {contract: {removed_file_ids: [removed.id]}},
          as: :turbo_stream

        expect(response).to be_successful
        expect(response.body).to include("placeholder-img.jpeg")
        expect(response.body).not_to include("test.pdf")
        expect(contract.reload.files.map { |file| file.filename.to_s }).to eq(["placeholder-img.jpeg"])
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch client_contract_url(client, contract), params: {contract: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes the requested contract" do
      contract
      expect {
        delete client_contract_url(client, contract)
      }.to change(Contract.kept, :count).by(-1)
      expect(contract.reload).to be_discarded
    end

    it "redirects to the client" do
      delete client_contract_url(client, contract)
      expect(response).to redirect_to(client_url(client))
    end
  end
end
