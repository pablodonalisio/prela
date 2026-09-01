require "rails_helper"

RSpec.describe Activity, type: :model do
  before do
    allow_any_instance_of(LocationEquipment).to receive(:create_initial_pending_occurrences!).and_return(nil)
  end

  it "is valid without a kind" do
    expect(build(:activity, kind: nil)).to be_valid
  end

  describe "service decoupling" do
    it "does not create a service date when an activity is created" do
      expect {
        create(:activity, date: Time.current)
      }.not_to change(ServiceDate, :count)
    end

    it "does not create a pending occurrence when an activity is created" do
      expect {
        create(:activity, date: Time.current)
      }.not_to change(ServiceOccurrence, :count)
    end
  end
end
