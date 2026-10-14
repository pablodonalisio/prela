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

RSpec.describe "GET /location_equipments/:id/qr_token", type: :request do
  let(:location_equipment) { create(:location_equipment) }

  it "creates a token on the first visit and reuses it" do
    sign_in create(:admin)

    get location_equipment_qr_token_path(location_equipment)

    token = location_equipment.reload.qr_token
    expect(token).to be_present
    expect(response).to be_successful
    expect(response.body).to include("<svg")
    expect(response.body).to include("<title>#{qr_url(token: token.token)}</title>")
    expect(response.body).to include(location_equipment.equipment.name)
    expect(response.body).to include("Imprimir")

    get location_equipment_qr_token_path(location_equipment)

    expect(location_equipment.reload.qr_token).to eq(token)
  end

  it "lets a technician open the label" do
    sign_in create(:technician)

    get location_equipment_qr_token_path(location_equipment)

    expect(response).to be_successful
    expect(location_equipment.reload.qr_token).to be_present
  end

  it "does not let a client open the label" do
    sign_in create(:user, role: :client)

    get location_equipment_qr_token_path(location_equipment)

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
    expect(location_equipment.reload.qr_token).to be_nil
  end

  it "links to the label from the equipment page for an admin" do
    sign_in create(:admin)

    get location_equipment_path(location_equipment)

    expect(response.body).to include("Etiqueta QR")
    expect(response.body).to include(location_equipment_qr_token_path(location_equipment))
  end
end
