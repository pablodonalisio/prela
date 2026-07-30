require "rails_helper"

RSpec.describe "/contacts", type: :request do
  let(:client) { create(:client) }
  let(:valid_attributes) {
    {name: "Ana Gómez", job_position: "Supervisora", work_area: "Mantenimiento", email: "ana@example.com", phone: "11-9999-0000"}
  }
  let(:invalid_attributes) {
    {name: "", job_position: "", work_area: ""}
  }
  let(:contact) { create(:contact, client:) }

  before { sign_in create(:admin) }

  describe "GET /new" do
    it "renders a successful response" do
      get new_client_contact_url(client)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_client_contact_url(client, contact)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Contact" do
        expect {
          post client_contacts_url(client), params: {contact: valid_attributes}
        }.to change(Contact, :count).by(1)
      end

      it "persists distance_above for a root" do
        post client_contacts_url(client), params: {contact: valid_attributes.merge(distance_above: 2)}

        expect(Contact.order(:id).last.distance_above).to eq(2)
      end

      it "persists distance_above when reporting to a superior" do
        manager = create(:contact, client:, name: "Manager")

        post client_contacts_url(client),
          params: {contact: valid_attributes.merge(reports_to_id: manager.id, distance_above: 2)}

        created = Contact.order(:id).last
        expect(created.reports_to).to eq(manager)
        expect(created.distance_above).to eq(2)
      end

      it "redirects to the client" do
        post client_contacts_url(client), params: {contact: valid_attributes}
        expect(response).to redirect_to(client_path(client))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Contact" do
        expect {
          post client_contacts_url(client), params: {contact: invalid_attributes}
        }.not_to change(Contact, :count)
      end

      it "renders a response with 422 status" do
        post client_contacts_url(client), params: {contact: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {name: "Ana Actualizada", job_position: "Gerente", work_area: "Compras"}
      }

      it "updates the requested contact" do
        patch client_contact_url(client, contact), params: {contact: new_attributes}
        contact.reload
        expect(contact.name).to eq("Ana Actualizada")
        expect(contact.job_position).to eq("Gerente")
        expect(contact.work_area).to eq("Compras")
      end

      it "persists distance_above" do
        patch client_contact_url(client, contact), params: {contact: {distance_above: 2}}
        expect(contact.reload.distance_above).to eq(2)
      end

      it "persists distance_above for a report under a superior" do
        manager = create(:contact, client:, name: "Manager")
        patch client_contact_url(client, contact),
          params: {contact: {reports_to_id: manager.id, distance_above: 3}}

        contact.reload
        expect(contact.reports_to).to eq(manager)
        expect(contact.distance_above).to eq(3)
      end

      it "redirects to the client" do
        patch client_contact_url(client, contact), params: {contact: new_attributes}
        expect(response).to redirect_to(client_url(client))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch client_contact_url(client, contact), params: {contact: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes the requested contact" do
      contact
      expect {
        delete client_contact_url(client, contact)
      }.to change(Contact.kept, :count).by(-1)
      expect(contact.reload).to be_discarded
    end

    it "redirects to the client" do
      delete client_contact_url(client, contact)
      expect(response).to redirect_to(client_url(client))
    end
  end
end
