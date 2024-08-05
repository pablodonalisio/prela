require "rails_helper"

RSpec.describe HomePolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show?, :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end

  permissions :index? do
    it_behaves_like "client level access policy"
  end
end
