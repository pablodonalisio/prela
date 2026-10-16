require "rails_helper"

RSpec.describe QrTokenPolicy, type: :policy do
  let(:admin) { create(:admin) }
  let(:technician) { create(:technician) }
  let(:client) { create(:user, role: :client) }
  let(:record) { QrToken.new }

  permissions :show? do
    it "grants access to admins and technicians" do
      expect(described_class).to permit(admin, record)
      expect(described_class).to permit(technician, record)
    end

    it "denies access to clients" do
      expect(described_class).not_to permit(client, record)
    end
  end
end
