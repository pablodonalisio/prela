require "rails_helper"

RSpec.describe "Application", type: :request do
  describe "GET /users/sign_out" do
    it "redirects to the login page" do
      sign_in create(:user)
      delete destroy_user_session_path
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(request.fullpath).to eq "/users/sign_in"
    end
  end
end
