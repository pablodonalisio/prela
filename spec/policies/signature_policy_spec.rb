require "rails_helper"

RSpec.describe SignaturePolicy, type: :policy do
  def create_signature(name:, user: nil)
    signature = Signature.new(name: name, title: "Cargo", user: user)
    signature.image.attach(io: StringIO.new("img"), filename: "sig.png", content_type: "image/png")
    signature.save!
    signature
  end

  describe "ReportScope" do
    subject(:scope) { described_class::ReportScope.new(user, Signature).resolve }

    let(:technician) { create(:technician) }
    let!(:shared_signature) { create_signature(name: "Compartida") }
    let!(:own_signature) { create_signature(name: "Propia", user: technician) }
    let!(:other_signature) { create_signature(name: "Ajena", user: create(:technician)) }

    context "when the user is a technician" do
      let(:user) { technician }

      it "returns unowned signatures and their own" do
        expect(scope).to contain_exactly(shared_signature, own_signature)
      end

      it "excludes discarded signatures" do
        shared_signature.discard

        expect(scope).to contain_exactly(own_signature)
      end
    end

    context "when the user is an admin" do
      let(:user) { create(:admin) }

      it "returns only unowned signatures" do
        expect(scope).to contain_exactly(shared_signature)
      end
    end

    context "when the user is a client editor" do
      let(:user) { create(:user, editor: true) }

      it "returns only unowned signatures" do
        expect(scope).to contain_exactly(shared_signature)
      end
    end
  end
end
