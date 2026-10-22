require "rails_helper"

RSpec.describe Contract, type: :model do
  let(:client) { create(:client) }

  it "is valid with a name, file, and dates" do
    expect(build(:contract, client:)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:contract, client:, name: "")).not_to be_valid
  end

  it "is not valid without a file" do
    expect(build(:contract, client:, file: nil)).not_to be_valid
  end

  it "is not valid without a start date" do
    expect(build(:contract, client:, starts_on: nil)).not_to be_valid
  end

  it "is not valid without an end date" do
    expect(build(:contract, client:, ends_on: nil)).not_to be_valid
  end

  it "is not valid when the end date is before the start date" do
    contract = build(:contract, client:, starts_on: Date.current, ends_on: Date.yesterday)

    expect(contract).not_to be_valid
    expect(contract.errors[:ends_on]).to include("debe ser posterior o igual a la fecha de inicio")
  end

  it "is valid when the end date is the same as the start date" do
    expect(build(:contract, client:, starts_on: Date.current, ends_on: Date.current)).to be_valid
  end

  it "attaches the contract file" do
    contract = create(:contract, client:)

    expect(contract.file).to be_attached
    expect(contract.file.filename.to_s).to eq("test.pdf")
  end
end
