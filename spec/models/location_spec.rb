require "rails_helper"

RSpec.describe Location, type: :model do
  context "validations" do
    let(:location) { build(:location) }

    it "is valid with valid attributes" do
      expect(location).to be_valid
    end

    it "is not valid without a name" do
      location.name = nil
      expect(location).not_to be_valid
    end
  end

  context "associations" do
    let(:location) { create(:location) }

    it "belongs to a client" do
      expect(location.client).to be_a(Client)
    end

    it "has many location equipments" do
      create_list(:location_equipment, 3, location: location)
      expect(location.location_equipments.size).to eq(3)
    end
  end
end
