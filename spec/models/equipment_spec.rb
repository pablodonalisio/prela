require "rails_helper"

RSpec.describe Equipment, type: :model do
  let(:equipment) { create(:equipment) }

  context "with supplies" do
    let(:supplies) { create_list(:battery, 2) }

    before do
      supplies.each { |supply| equipment.equipment_supplies.create(suppliable: supply) }
    end

    it "should have many supplies" do
      expect(equipment.equipment_supplies.size).to eq(2)
    end
  end
end
