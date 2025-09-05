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

  describe "full_role" do
    let(:admin) { create(:user, role: "admin") }
    let(:client) { create(:user, role: "client", editor: false) }
    let(:client_editor) { create(:user, role: "client", editor: true) }

    it "should return 'Admin' for admin role" do
      expect(admin.full_role).to eq("Admin")
    end

    it "should return 'Cliente (Editor)' for client role with editor" do
      expect(client_editor.full_role).to eq("Cliente (Editor)")
    end

    it "should return 'Cliente' for client role without editor" do
      expect(client.full_role).to eq("Cliente")
    end

    it "should raise an error for undefined role" do
      allow(client).to receive(:role).and_return("undefined_role")
      expect { client.full_role }.to raise_error(StandardError, "Undefined role")
    end
  end
end
