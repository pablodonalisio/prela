require "rails_helper"

RSpec.describe Report, type: :model do
  context "associations" do
    let(:report) { create(:report) }

    it "belongs to a location_equipment" do
      expect(report.location_equipment).to be_a(LocationEquipment)
    end
  end
end
