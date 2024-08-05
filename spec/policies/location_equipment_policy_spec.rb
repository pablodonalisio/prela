require "rails_helper"
require "support/policy_shared_examples"

RSpec.describe LocationEquipmentPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  describe "#policy_scope" do
    let(:client_user) { create(:user, role: :client) }
    let(:client) { create(:client, users: [client_user]) }
    let(:another_client) { create(:client) }
    let(:client_location) { create(:location, client: client) }
    let(:another_client_location) { create(:location, client: another_client) }
    let!(:client_location_equipment) { create(:location_equipment, location: client_location) }
    let!(:another_client_location_equipment) { create(:location_equipment, location: another_client_location) }

    it "returns all location equipment for admin" do
      location_equipments = [client_location_equipment, another_client_location_equipment]
      expect(Pundit.policy_scope(admin, LocationEquipment)).to match_array(location_equipments)
    end

    it "returns client's location equipment for client" do
      location_equipments = [client_location_equipment]
      expect(Pundit.policy_scope(client_user, LocationEquipment)).to match_array(location_equipments)
    end
  end

  permissions :show?, :index? do
    it_behaves_like "client level access policy"
  end

  permissions :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end
end
