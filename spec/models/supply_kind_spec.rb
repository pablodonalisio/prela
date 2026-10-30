require "rails_helper"

RSpec.describe SupplyKind, type: :model do
  it "is valid with a name" do
    expect(build(:supply_kind)).to be_valid
  end

  it "is valid without a description" do
    expect(build(:supply_kind, description: nil)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:supply_kind, name: nil)).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case and accents" do
    create(:supply_kind, name: "Batería")
    supply_kind = build(:supply_kind, name: "bateria")
    expect(supply_kind).not_to be_valid
    expect(supply_kind.errors[:name]).to be_present
  end

  it "allows reusing a discarded name" do
    discarded = create(:supply_kind, name: "Aceite")
    discarded.discard!
    expect(build(:supply_kind, name: "Aceite")).to be_valid
  end

  it "discards when no kept supplies use it" do
    supply_kind = create(:supply_kind)
    create(:supply, supply_kind: supply_kind).discard!

    expect(supply_kind.discard).to be(true)
    expect(supply_kind.reload).to be_discarded
  end

  it "does not discard while kept supplies use it" do
    supply_kind = create(:supply_kind)
    create(:supply, supply_kind: supply_kind)

    expect(supply_kind.discard).to be(false)
    expect(supply_kind.errors[:base]).to include("No se puede eliminar el tipo porque tiene insumos.")
    expect(supply_kind.reload).not_to be_discarded
  end
end
