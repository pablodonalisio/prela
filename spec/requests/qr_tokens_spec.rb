require "rails_helper"

RSpec.describe "GET /q/:token", type: :request do
  let(:location_equipment) { create(:location_equipment) }
  let(:qr_token) { location_equipment.ensure_qr_token! }

  it "redirects a signed-in technician to the location equipment" do
    sign_in create(:technician)

    get qr_path(token: qr_token.token)

    expect(response).to redirect_to(location_equipment_path(location_equipment))
  end

  it "returns not found for an unknown token" do
    sign_in create(:technician)

    get qr_path(token: "missing-token")

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found for a discarded token" do
    sign_in create(:technician)
    qr_token.discard!

    get qr_path(token: qr_token.token)

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found for discarded equipment" do
    sign_in create(:technician)
    qr_token
    location_equipment.discard!

    get qr_path(token: qr_token.token)

    expect(response).to have_http_status(:not_found)
  end

  it "redirects a logged-out request to sign in" do
    get qr_path(token: qr_token.token)

    expect(response).to redirect_to(new_user_session_path)
  end
end
