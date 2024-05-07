require "rails_helper"

RSpec.describe Report, type: :model do
  context "associations" do
    let(:report) { create(:report) }

    it "belongs to a location_equipment" do
      expect(report.location_equipment).to be_a(LocationEquipment)
    end

    it "is invalid with a date greater than the current date" do
      report.date = Time.zone.tomorrow + 1.day
      expect(report).to_not be_valid
    end

    it "is valid with a date less than the current date" do
      report.date = Time.zone.now
      expect(report).to be_valid
    end
  end
end
