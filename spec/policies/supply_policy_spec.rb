require "rails_helper"

RSpec.describe SupplyPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show?, :index?, :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end

  describe "Scope" do
    let(:technician) { create(:technician) }
    let!(:supply) { create(:supply) }
    let!(:discarded) { create(:supply).tap(&:discard!) }

    it "returns kept supplies for an admin or technician" do
      expect(Pundit.policy_scope(admin, Supply)).to contain_exactly(supply)
      expect(Pundit.policy_scope(technician, Supply)).to contain_exactly(supply)
    end

    it "hides discarded supplies" do
      expect(Pundit.policy_scope(admin, Supply)).not_to include(discarded)
    end
  end
end
