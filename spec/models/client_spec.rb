require "rails_helper"

RSpec.describe Client, type: :model do
  let!(:client) { create(:client) }

  it "is valid with valid attributes" do
    expect(build(:client)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:client, name: "")).not_to be_valid
  end

  it "can have many locations" do
    location1 = create(:location, client:)
    location2 = create(:location, client:)

    expect(client.locations).to include(location1, location2)
  end

  it "deletes associated locations when deleted" do
    create(:location, client:)

    expect { client.destroy }.to change { Location.count }.by(-1)
  end

  it "can have an attached avatar" do
    client.avatar.attach(io: File.open(Rails.root.join("spec", "test_files", "placeholder-img.jpeg")), filename: "placeholder-img.jpeg", content_type: "image/jpg")

    expect(client.avatar).to be_attached
  end
end
