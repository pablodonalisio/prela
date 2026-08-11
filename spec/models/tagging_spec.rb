require "rails_helper"

RSpec.describe Tagging, type: :model do
  it "is valid with a tag and taggable" do
    tagging = build(:tagging)
    expect(tagging).to be_valid
  end

  it "does not allow the same tag twice on the same taggable" do
    tagging = create(:tagging)
    duplicate = Tagging.new(tag: tagging.tag, taggable: tagging.taggable)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:tag_id]).to be_present
  end

  it "allows the same tag on different taggables" do
    tag = create(:tag)
    create(:tagging, tag: tag, taggable: create(:location_equipment))
    other = build(:tagging, tag: tag, taggable: create(:location_equipment))

    expect(other).to be_valid
  end
end
