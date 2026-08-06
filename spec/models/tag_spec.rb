require "rails_helper"

RSpec.describe Tag, type: :model do
  it "is valid with a name and hex color" do
    expect(Tag.new(name: "Inaccesible", color: "#ff9900")).to be_valid
  end

  it "is not valid without a name" do
    expect(Tag.new(name: nil)).not_to be_valid
  end

  it "is not valid with an invalid color" do
    tag = Tag.new(name: "Inaccesible", color: "purple")
    expect(tag).not_to be_valid
    expect(tag.errors[:color]).to be_present
  end

  it "normalizes colors without a hash prefix" do
    tag = Tag.create!(name: "Inaccesible", color: "FF9900")
    expect(tag.color).to eq("#ff9900")
  end

  it "defaults color to the default hex" do
    expect(Tag.create!(name: "Inaccesible").color).to eq(Tag::DEFAULT_COLOR)
  end

  describe "#badge_style" do
    it "uses the hex color as background" do
      tag = Tag.new(name: "Inaccesible", color: "#dc3545")
      expect(tag.badge_style).to include("background-color: #dc3545")
    end
  end

  describe "#location_equipments_count" do
    it "counts visible location equipments with the tag" do
      tag = create(:tag)
      kept = create(:location_equipment)
      discarded = create(:location_equipment)
      create(:tagging, tag: tag, taggable: kept)
      create(:tagging, tag: tag, taggable: discarded)
      discarded.discard!

      expect(tag.location_equipments_count).to eq(1)
    end
  end


  describe "#contrast_text_color" do
    it "uses dark text on light backgrounds" do
      tag = Tag.new(name: "Claro", color: "#ffc107")
      expect(tag.contrast_text_color).to eq("#212529")
    end

    it "uses light text on dark backgrounds" do
      tag = Tag.new(name: "Oscuro", color: "#212529")
      expect(tag.contrast_text_color).to eq("#ffffff")
    end
  end



  it "is not valid with a duplicate name" do
    Tag.create!(name: "Inaccesible")
    expect(Tag.new(name: "Inaccesible")).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case" do
    Tag.create!(name: "Inaccesible")
    tag = Tag.new(name: "INACCESIBLE")
    expect(tag).not_to be_valid
    expect(tag.errors[:name]).to be_present
  end

  it "is not valid with a duplicate name ignoring accents" do
    Tag.create!(name: "Revisión")
    tag = Tag.new(name: "revision")
    expect(tag).not_to be_valid
    expect(tag.errors[:name]).to be_present
  end

  it "allows reusing a name after soft-delete" do
    tag = Tag.create!(name: "Inaccesible")
    tag.discard!
    expect(Tag.new(name: "Inaccesible")).to be_valid
  end

  describe ".visible" do
    it "excludes discarded tags" do
      kept = Tag.create!(name: "Kept")
      discarded = Tag.create!(name: "Discarded")
      discarded.discard!

      expect(Tag.visible).to include(kept)
      expect(Tag.visible).not_to include(discarded)
    end
  end

  describe ".normalize_name" do
    it "downcases, strips, and removes accents" do
      expect(described_class.normalize_name("  Revisión PRELA  ")).to eq("revision prela")
    end
  end

  it "keeps taggings when discarded so they return after undiscard" do
    tag = create(:tag)
    location_equipment = create(:location_equipment)
    tagging = create(:tagging, tag: tag, taggable: location_equipment)

    tag.discard!

    expect(Tagging.exists?(tagging.id)).to be(true)
    expect(location_equipment.tags.kept).not_to include(tag)

    tag.undiscard!

    expect(location_equipment.tags.kept).to include(tag)
  end
end

