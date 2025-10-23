require "rails_helper"

RSpec.describe Failure, type: :model do
  let(:subject) { build(:failure) }
  describe "validations" do
    it { is_expected.to be_valid }
    it "is not valid without a location_equipment" do
      subject.location_equipment = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a description" do
      subject.description = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a date" do
      subject.date = nil
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a location_equipment" do
      expect(subject.location_equipment).to be_present
    end
  end
end
