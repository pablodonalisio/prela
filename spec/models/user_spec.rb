require "rails_helper"

RSpec.describe User, type: :model do
  describe "roles" do
    let(:user) { create(:user) }

    it "should have a default role of client" do
      expect(user.role).to eq("client")
    end

    it "should have an admin role" do
      user.update(role: "admin")
      expect(user.role).to eq("admin")
    end

    it "should be invalid without a role" do
      user.role = nil
      expect(user).not_to be_valid
    end
  end
end
