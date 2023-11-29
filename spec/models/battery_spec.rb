require "rails_helper"

RSpec.describe Battery, type: :model do
  context "with valid attributes" do
    let(:battery) { build(:battery) }

    it "is valid with valid attributes" do
      expect(battery).to be_valid
    end
  end

  context "with invalid attributes" do
    let(:battery) { build(:battery) }

    it "is not valid without a model" do
      battery.model = nil
      expect(battery).not_to be_valid
    end

    it "is not valid without a voltage" do
      battery.voltage = nil
      expect(battery).not_to be_valid
    end

    it "is not valid without amps" do
      battery.amps = nil
      expect(battery).not_to be_valid
    end
  end

  context "with associations" do
    let(:battery) { create(:battery) }

    it "can have many equipment_supplies" do
      equipment_supply1 = create(:equipment_supply, suppliable: battery)
      equipment_supply2 = create(:equipment_supply, suppliable: battery)

      expect(battery.equipment_supplies).to include(equipment_supply1, equipment_supply2)
    end

    it "deletes associated equipment_supplies when deleted" do
      create(:equipment_supply, suppliable: battery)

      expect { battery.destroy }.to change { EquipmentSupply.count }.by(-1)
    end

    it "can have an attached avatar" do
      battery.avatar.attach(io: File.open(Rails.root.join("spec", "test_files", "placeholder-img.jpeg")), filename: "placeholder-img.jpeg", content_type: "image/jpeg")

      expect(battery.avatar).to be_attached
    end
  end
end
