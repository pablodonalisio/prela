require "rails_helper"

RSpec.describe "Supplies", type: :request do
  before { sign_in create(:user) }

  describe "GET /index" do
    it "returns http success" do
      get supplies_path
      expect(response).to have_http_status(:success)
    end
  end
end
