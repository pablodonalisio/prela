require "rails_helper"

RSpec.describe "/service_kinds", type: :request do
  let(:valid_attributes) {
    {
      name: "Inspección térmica",
      default_interval: 3,
      interval_unit: "months",
      priority: "critical"
    }
  }
  let(:invalid_attributes) { {name: nil, default_interval: 1} }
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      create(:service_kind)
      get service_kinds_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get service_kinds_url
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_service_kind_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get new_service_kind_url
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      service_kind = create(:service_kind)
      get edit_service_kind_url(service_kind)
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        service_kind = create(:service_kind)
        get edit_service_kind_url(service_kind)
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new ServiceKind without a legacy_key" do
        expect {
          post service_kinds_url, params: {service_kind: valid_attributes}
        }.to change(ServiceKind, :count).by(1)
        expect(ServiceKind.order(:id).last.legacy_key).to be_nil
      end

      it "ignores legacy_key in params" do
        post service_kinds_url, params: {
          service_kind: valid_attributes.merge(legacy_key: "should_not_stick")
        }
        expect(ServiceKind.order(:id).last.legacy_key).to be_nil
      end

      it "redirects to the service kinds list" do
        post service_kinds_url, params: {service_kind: valid_attributes}
        expect(response).to redirect_to(service_kinds_url)
      end

      it "creates a one-time service kind without interval fields" do
        expect {
          post service_kinds_url, params: {
            service_kind: {
              name: "Inspección inicial",
              recurring: "0",
              priority: "normal"
            }
          }
        }.to change(ServiceKind, :count).by(1)

        service_kind = ServiceKind.order(:id).last
        expect(service_kind).not_to be_recurring
        expect(service_kind.default_interval).to be_nil
        expect(service_kind.interval_unit).to be_nil
      end

      it "appends the service kind via turbo stream" do
        post service_kinds_url, params: {service_kind: valid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('turbo-stream action="append" target="service_kinds"')
      end
    end

    context "with invalid parameters" do
      it "does not create a new ServiceKind" do
        expect {
          post service_kinds_url, params: {service_kind: invalid_attributes}
        }.to change(ServiceKind, :count).by(0)
      end

      it "renders a response with 422 status" do
        post service_kinds_url, params: {service_kind: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the form via turbo stream" do
        post service_kinds_url, params: {service_kind: invalid_attributes}, as: :turbo_stream
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('turbo-stream action="update" target="remote_modal_body"')
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          name: "Inspección actualizada",
          default_interval: 2,
          interval_unit: "weeks",
          priority: "low"
        }
      }

      it "updates the requested service kind" do
        service_kind = create(:service_kind)
        patch service_kind_url(service_kind), params: {service_kind: new_attributes}
        service_kind.reload
        expect(service_kind.name).to eq "Inspección actualizada"
        expect(service_kind.default_interval).to eq 2
        expect(service_kind.interval_unit).to eq "weeks"
        expect(service_kind.priority).to eq "low"
      end

      it "does not change legacy_key via params" do
        service_kind = create(:service_kind, :with_legacy_key)
        original_key = service_kind.legacy_key
        patch service_kind_url(service_kind), params: {
          service_kind: new_attributes.merge(legacy_key: "hacked")
        }
        expect(service_kind.reload.legacy_key).to eq(original_key)
      end

      it "redirects to the service kinds list" do
        service_kind = create(:service_kind)
        patch service_kind_url(service_kind), params: {service_kind: new_attributes}
        expect(response).to redirect_to(service_kinds_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        service_kind = create(:service_kind)
        patch service_kind_url(service_kind), params: {service_kind: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes the requested service kind" do
      service_kind = create(:service_kind)
      expect {
        delete service_kind_url(service_kind)
      }.to change(ServiceKind.kept, :count).by(-1)
      expect(service_kind.reload).to be_discarded
    end

    it "redirects to the service kinds list" do
      service_kind = create(:service_kind)
      delete service_kind_url(service_kind)
      expect(response).to redirect_to(service_kinds_url)
    end
  end
end
