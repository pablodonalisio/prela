require 'rails_helper'

RSpec.describe "Supplies", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/supplies/index"
      expect(response).to have_http_status(:success)
    end
  end

end
