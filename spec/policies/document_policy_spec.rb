require "rails_helper"
require "support/policy_shared_examples"

RSpec.describe DocumentPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:client) { create(:user, role: :client) }

  subject { described_class }

  describe "#policy_scope" do
    let!(:public_document) { create(:document, public: true) }
    let!(:private_document) { create(:document, public: false) }

    it "returns all documents for admin" do
      expect(Pundit.policy_scope(admin, Document)).to match_array([public_document, private_document])
    end

    it "returns only public documents for client" do
      expect(Pundit.policy_scope(client, Document)).to match_array([public_document])
    end
  end

  permissions :show? do
    it "grants access to admin for private documents" do
      expect(subject).to permit(admin, create(:document, public: false))
    end

    it "grants access to client for public documents" do
      expect(subject).to permit(client, create(:document, public: true))
    end

    it "denies access to client for private documents" do
      expect(subject).not_to permit(client, create(:document, public: false))
    end
  end

  permissions :index? do
    it_behaves_like "client level access policy"
  end

  permissions :create?, :update?, :destroy? do
    it_behaves_like "admin level access policy"
  end
end
