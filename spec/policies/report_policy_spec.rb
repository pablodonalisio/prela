require "rails_helper"

RSpec.describe ReportPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  permissions :show? do
    it_behaves_like "client level access policy", :report
  end

  permissions :index? do
    it_behaves_like "client level access policy", :report
  end

  permissions :create? do
    it_behaves_like "admin level access policy", :report
  end

  permissions :update? do
    it_behaves_like "admin level access policy", :report
  end

  permissions :destroy? do
    it_behaves_like "admin level access policy", :report
  end
end
