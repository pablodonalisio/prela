require "rails_helper"

RSpec.describe Client, type: :model do
  it "is valid with valid attributes" do
    expect(build(:client)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:client, name: "")).not_to be_valid
  end
end
