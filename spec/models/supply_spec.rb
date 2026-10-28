require "rails_helper"

RSpec.describe Supply, type: :model do
  it "is valid with required attributes" do
    expect(build(:supply)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:supply, name: nil)).not_to be_valid
  end

  it "is not valid without a kind" do
    expect(build(:supply, supply_kind: nil)).not_to be_valid
  end

  it "is not valid with a discarded kind" do
    supply_kind = create(:supply_kind)
    supply_kind.discard!
    expect(build(:supply, supply_kind: supply_kind)).not_to be_valid
  end

  it "finds supplies by a partial name ignoring case and accents" do
    battery = create(:supply, name: "Batería CSB")
    create(:supply, name: "Correa A-42")

    expect(Supply.by_name("bateria")).to contain_exactly(battery)
  end

  it "finds a supply when each search word appears anywhere in the name" do
    oil = create(:supply, name: "Aceite hidráulico ISO 68")
    create(:supply, name: "Aceite 15W40")

    expect(Supply.by_name("Aceite iso 68")).to contain_exactly(oil)
    expect(Supply.by_name("68 aceite")).to contain_exactly(oil)
  end

  it "is not valid with a duplicate name ignoring case and accents" do
    create(:supply, name: "Aceite 15W40")
    supply = build(:supply, name: "aceite 15w40")
    expect(supply).not_to be_valid
    expect(supply.errors[:name]).to be_present
  end

  it "allows reusing a discarded name" do
    discarded = create(:supply, name: "Correa A42")
    discarded.discard!
    expect(build(:supply, name: "Correa A42")).to be_valid
  end

  it "accepts a blank reference url" do
    expect(build(:supply, reference_url: "  ")).to be_valid
  end

  it "rejects a reference url that is not http or https" do
    expect(build(:supply, reference_url: "ftp://example.com/oil")).not_to be_valid
  end

  it "stores a replacement once and shows it from both supplies" do
    oil = create(:supply, name: "Aceite 15W40")
    equivalent = create(:supply, name: "Aceite equivalente")

    oil.update!(replacement_ids: [equivalent.id])

    expect(SupplyReplacement.count).to eq(1)
    expect(oil.replacement_supplies).to contain_exactly(equivalent)
    expect(equivalent.reload.replacement_supplies).to contain_exactly(oil)
  end

  it "keeps a single pair when both sides list each other" do
    oil = create(:supply)
    equivalent = create(:supply)
    oil.update!(replacement_ids: [equivalent.id])
    equivalent.update!(replacement_ids: [oil.id])

    expect(SupplyReplacement.count).to eq(1)
  end

  it "ignores itself as a replacement" do
    supply = create(:supply)
    other = create(:supply)

    supply.update!(replacement_ids: [supply.id, other.id])

    expect(supply.replacement_supplies).to contain_exactly(other)
  end

  it "clears replacements" do
    supply = create(:supply)
    other = create(:supply)
    supply.update!(replacement_ids: [other.id])

    supply.update!(replacement_ids: [])

    expect(supply.replacement_supplies).to be_empty
    expect(SupplyReplacement.count).to eq(0)
  end

  it "removes replacement pairs when discarded" do
    supply = create(:supply)
    other = create(:supply)
    supply.update!(replacement_ids: [other.id])

    supply.discard!

    expect(SupplyReplacement.count).to eq(0)
    expect(other.reload.replacement_supplies).to be_empty
  end
end
