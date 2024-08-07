require "rails_helper"

RSpec.describe EquipmentPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show?, :index?, :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end
end
