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

  it "soft-deletes without destroying locations" do
    location = create(:location, client:)

    expect { client.discard }.to change { Client.kept.count }.by(-1)
    expect(location.reload).to be_kept
    expect(Location.visible).not_to include(location)
  end

  describe ".visible" do
    it "excludes discarded clients" do
      kept_client = create(:client)
      discarded_client = create(:client)
      discarded_client.discard

      expect(Client.visible).to include(kept_client)
      expect(Client.visible).not_to include(discarded_client)
    end
  end


  it "can have an attached avatar" do
    client.avatar.attach(io: File.open(Rails.root.join("spec", "test_files", "placeholder-img.jpeg")), filename: "placeholder-img.jpeg", content_type: "image/jpg")

    expect(client.avatar).to be_attached
  end
end
