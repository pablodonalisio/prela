require "rails_helper"

RSpec.describe Document, type: :model do
  let(:subject) { build(:document) }
  describe "validations" do
    it { is_expected.to be_valid }
    it { expect(subject.file).to be_attached }
    it "is not valid without a description" do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a file" do
      subject.file = nil
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a documentable" do
      expect(subject.documentable).to be_present
    end
  end

  describe "defaults" do
    it "defaults public to false for new documents" do
      document = create(:document)
      expect(document.public).to be(false)
    end
  end

  describe ".client_visible" do
    let!(:public_document) { create(:document, public: true) }
    let!(:private_document) { create(:document, public: false) }

    it "returns only public documents" do
      expect(Document.client_visible).to contain_exactly(public_document)
    end
  end
end
