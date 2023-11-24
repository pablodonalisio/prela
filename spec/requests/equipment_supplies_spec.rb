require 'rails_helper'

RSpec.describe "EquipmentSupplies", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/equipment_supplies/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/equipment_supplies/create"
      expect(response).to have_http_status(:success)
    end
  end

end
