require "rails_helper"

RSpec.describe SupplyReplacement, type: :model do
  it "stores the pair with the lower id first" do
    first = create(:supply)
    second = create(:supply)
    low, high = [first, second].minmax_by(&:id)

    pair = described_class.create!(supply: high, replacement: low)

    expect(pair.supply_id).to eq(low.id)
    expect(pair.replacement_id).to eq(high.id)
  end

  it "is not valid when both sides are the same supply" do
    supply = create(:supply)
    pair = described_class.new(supply: supply, replacement: supply)

    expect(pair).not_to be_valid
  end
end
