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

  describe ".visible" do
    it "excludes discarded locations and locations with discarded clients" do
      visible_location = create(:location)
      discarded_location = create(:location)
      discarded_location.discard
      location_with_discarded_client = create(:location)
      location_with_discarded_client.client.discard

      expect(Location.visible).to include(visible_location)
      expect(Location.visible).not_to include(discarded_location)
      expect(Location.visible).not_to include(location_with_discarded_client)
      expect(location_with_discarded_client.reload).to be_kept
    end

    it "includes locations again after undiscarding the client" do
      location = create(:location)
      location.client.discard

      expect(Location.visible).not_to include(location)

      location.client.undiscard

      expect(Location.visible).to include(location)
    end
  end
end

