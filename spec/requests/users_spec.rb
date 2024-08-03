require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user, role: "admin") }

    it "returns a successful response and displays client users" do
      get users_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user1.email)
      expect(response.body).to include(user2.email)
      expect(response.body).not_to include(user3.email)
    end
  end
end
