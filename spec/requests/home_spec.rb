require "rails_helper"

RSpec.describe "Homes", type: :request do
  before { sign_in create(:user) }

  describe "GET /index" do
    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:redirect)
    end
  end
end
