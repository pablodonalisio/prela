require "rails_helper"
require "support/policy_shared_examples"

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show?, :index?, :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end
end
