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
end
