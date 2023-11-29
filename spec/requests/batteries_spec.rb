require "rails_helper"

RSpec.describe "Batteries", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { {battery: {model: "BP5-12", voltage: 12, amps: 7}} }
  let(:invalid_attributes) { {battery: {model: "", voltage: "", amps: ""}} }
  let(:battery) { create(:battery) }

  before do
    sign_in user
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_battery_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns a successful response" do
      get edit_battery_path(battery)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns a successful response" do
      get battery_path(battery)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Battery and redirects to supplies_path" do
        expect {
          post batteries_path, params: valid_attributes
        }.to change(Battery, :count).by(1)

        expect(response).to redirect_to(supplies_path)
      end

      it "creates a new Battery and responds with turbo_stream" do
        expect {
          post batteries_path, params: valid_attributes, as: :turbo_stream
        }.to change(Battery, :count).by(1)

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"append\" target=\"batteries\"")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Battery and renders the new template" do
        expect {
          post batteries_path, params: invalid_attributes
        }.not_to change(Battery, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new Battery and responds with turbo_stream" do
        expect {
          post batteries_path, params: invalid_attributes, as: :turbo_stream
        }.not_to change(Battery, :count)

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"update\" target=\"remote_modal_body\"")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested Battery and redirects to supplies_url" do
        patch battery_path(battery), params: valid_attributes
        expect(response).to redirect_to(supplies_url)
      end

      it "updates the requested Battery and responds with turbo_stream" do
        patch battery_path(battery), params: valid_attributes, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"replace\" target=\"battery_#{battery.id}\"")
      end
    end

    context "with invalid parameters" do
      it "does not update the Battery and renders the edit template" do
        patch battery_path(battery), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the Battery and responds with turbo_stream" do
        patch battery_path(battery), params: invalid_attributes, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include("turbo-stream action=\"update\" target=\"remote_modal_body\"")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested Battery and redirects to supplies_url" do
      battery
      expect {
        delete battery_path(battery)
      }.to change(Battery, :count).by(-1)

      expect(response).to redirect_to(supplies_url)
    end

    it "destroys the requested Battery and responds with turbo_stream" do
      battery
      expect {
        delete battery_path(battery), as: :turbo_stream
      }.to change(Battery, :count).by(-1)

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"battery_#{battery.id}\"")
    end
  end
end
