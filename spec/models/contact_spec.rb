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

  it "belongs to an optional location of the same client" do
    location = create(:location, client:)
    contact = create(:contact, client:, location:)

    expect(contact.location).to eq(location)
  end

  it "rejects a location from another client" do
    other_location = create(:location)
    contact = build(:contact, client:, location: other_location)

    expect(contact).not_to be_valid
    expect(contact.errors[:location]).to be_present
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
    middle = create(:contact, client:, name: "Middle", reports_to: manager)
    leaf = create(:contact, client:, name: "Leaf", reports_to: middle)

    manager.reports_to = leaf

    expect(manager).not_to be_valid
    expect(manager.errors[:reports_to]).to be_present
  end

  it "nullifies direct reports when discarded" do
    manager = create(:contact, client:, name: "Manager")
    report = create(:contact, client:, name: "Report", reports_to: manager)

    manager.discard!

    expect(report.reload.reports_to_id).to be_nil
    expect(manager.reload).to be_discarded
  end

  describe ".roots" do
    it "returns kept contacts without a manager" do
      root = create(:contact, client:, name: "Root")
      create(:contact, client:, name: "Child", reports_to: root)
      discarded_root = create(:contact, client:, name: "Discarded")
      discarded_root.discard!

      expect(Contact.roots).to include(root)
      expect(Contact.roots.map(&:name)).not_to include("Child", "Discarded")
    end
  end
end
