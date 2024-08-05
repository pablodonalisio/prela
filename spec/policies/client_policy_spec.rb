require "rails_helper"

RSpec.describe ClientPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show?, :index?, :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end

  describe "#policy_scope" do
    let(:admin) { create(:user, role: :admin) }
    let(:user) { create(:user, role: :client) }
    let!(:client) { create(:client, users: [user]) }
    let!(:another_client) { create(:client) }

    it "returns only the client associated with the user" do
      expect(ClientPolicy::Scope.new(user, Client).resolve).to eq([user.client])
    end

    it "returns all clients for an admin" do
      expect(ClientPolicy::Scope.new(admin, Client).resolve).to eq(Client.all)
    end
  end
end
