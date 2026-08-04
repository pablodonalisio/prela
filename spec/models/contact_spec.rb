require "rails_helper"

RSpec.describe Contact, type: :model do
  let(:client) { create(:client) }

  it "is valid with valid attributes" do
    expect(build(:contact, client:)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:contact, client:, name: "")).not_to be_valid
  end

  it "is not valid without a work area" do
    expect(build(:contact, client:, work_area: "")).not_to be_valid
  end

  it "is not valid without a job position" do
    expect(build(:contact, client:, job_position: "")).not_to be_valid
  end

  it "is not valid with an invalid email" do
    expect(build(:contact, client:, email: "not-an-email")).not_to be_valid
  end

  it "allows blank email" do
    expect(build(:contact, client:, email: "")).to be_valid
  end

  it "can have many locations of the same client" do
    location1 = create(:location, client:)
    location2 = create(:location, client:)
    contact = create(:contact, client:, locations: [location1, location2])

    expect(contact.locations).to contain_exactly(location1, location2)
  end

  it "rejects a location from another client" do
    other_location = create(:location)
    contact = build(:contact, client:, locations: [other_location])

    expect(contact).not_to be_valid
    expect(contact.errors[:locations]).to be_present
  end

  it "rejects a manager from another client" do
    other_manager = create(:contact)
    contact = build(:contact, client:, reports_to: other_manager)

    expect(contact).not_to be_valid
    expect(contact.errors[:reports_to]).to be_present
  end

  it "rejects reporting to itself" do
    contact = create(:contact, client:)
    contact.reports_to = contact

    expect(contact).not_to be_valid
    expect(contact.errors[:reports_to]).to be_present
  end

  it "rejects a cycle in the reporting chain" do
    manager = create(:contact, client:, name: "Manager")
    middle = create(:contact, client:, name: "Middle", reports_to: manager, distance_above: 1)
    leaf = create(:contact, client:, name: "Leaf", reports_to: middle, distance_above: 1)

    manager.reports_to = leaf

    expect(manager).not_to be_valid
    expect(manager.errors[:reports_to]).to be_present
  end

  it "nullifies direct reports when discarded" do
    manager = create(:contact, client:, name: "Manager")
    report = create(:contact, client:, name: "Report", reports_to: manager, distance_above: 1)

    manager.discard!

    expect(report.reload.reports_to_id).to be_nil
    expect(manager.reload).to be_discarded
  end

  describe "distance_above" do
    it "allows 0 for roots" do
      expect(build(:contact, client:, distance_above: 0)).to be_valid
    end

    it "rejects negative values" do
      contact = build(:contact, client:, distance_above: -1)

      expect(contact).not_to be_valid
      expect(contact.errors[:distance_above]).to be_present
    end

    it "accepts 1 or more when reporting to a superior" do
      manager = create(:contact, client:)
      contact = build(:contact, client:, reports_to: manager, distance_above: 2)

      expect(contact).to be_valid
      expect(contact.distance_above).to eq(2)
    end

    it "bumps 0 to 1 when a superior is assigned" do
      manager = create(:contact, client:)
      contact = build(:contact, client:, reports_to: manager, distance_above: 0)

      expect(contact).to be_valid
      expect(contact.distance_above).to eq(1)
    end

    it "computes path_depth as the sum of distance_above along the chain" do
      root = create(:contact, client:, distance_above: 0)
      manager = create(:contact, client:, reports_to: root, distance_above: 1)
      report = build(:contact, client:, reports_to: manager, distance_above: 2)

      expect(root.path_depth).to eq(0)
      expect(manager.path_depth).to eq(1)
      expect(report.path_depth).to eq(3)
    end

    it "places disconnected roots by their own distance_above" do
      root = build(:contact, client:, distance_above: 2)

      expect(root.path_depth).to eq(2)
    end

    it "computes organigram_extra_spacers for roots and reports" do
      root = build(:contact, client:, distance_above: 2)
      manager = create(:contact, client:)
      report = build(:contact, client:, reports_to: manager, distance_above: 3)

      expect(root.organigram_extra_spacers).to eq(2)
      expect(report.organigram_extra_spacers).to eq(2)
    end
  end

  describe ".roots" do
    it "returns kept contacts without a manager" do
      root = create(:contact, client:, name: "Root")
      create(:contact, client:, name: "Child", reports_to: root, distance_above: 1)
      discarded_root = create(:contact, client:, name: "Discarded")
      discarded_root.discard!

      expect(Contact.roots).to include(root)
      expect(Contact.roots.map(&:name)).not_to include("Child", "Discarded")
    end
  end
end
