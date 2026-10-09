require "rails_helper"

RSpec.describe AssetType, type: :model do
  it "is valid with a name" do
    expect(AssetType.new(name: "Generador")).to be_valid
  end

  it "is not valid without a name" do
    expect(AssetType.new(name: nil)).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case" do
    AssetType.create!(name: "Generador")
    asset_type = AssetType.new(name: "generador")
    expect(asset_type).not_to be_valid
    expect(asset_type.errors[:name]).to be_present
  end

  describe ".ups" do
    it "creates the UPS type once" do
      first = AssetType.ups
      second = AssetType.ups

      expect(first.name).to eq("UPS")
      expect(first.system_key).to eq("ups")
      expect(second).to eq(first)
    end

    it "creates a new kept UPS after the previous one was discarded" do
      discarded = AssetType.ups
      discarded.discard

      replacement = AssetType.ups

      expect(replacement).not_to eq(discarded)
      expect(replacement).to be_kept
      expect(replacement.name).to eq("UPS")
    end
  end

  describe "#update" do
    it "renames UPS" do
      ups = AssetType.ups

      expect(ups.update(name: "Respaldo")).to be(true)
      expect(ups.reload.name).to eq("Respaldo")
    end
  end

  describe "#discard" do
    it "discards UPS when no equipment kind uses it" do
      ups = AssetType.ups

      expect(ups.discard).to be(true)
      expect(ups.reload).to be_discarded
      expect(AssetType.visible.find_by(system_key: "ups")).to be_nil
    end

    it "does not discard UPS when an equipment kind uses it" do
      ups = AssetType.ups
      create(:equipment_kind, name: "a1", asset_type: ups)

      expect(ups.discard).to be(false)
      expect(ups).not_to be_discarded
      expect(ups.errors[:base]).to include("No se puede eliminar porque hay otros equipos asociados.")
    end

    it "discards a type that no equipment kind uses" do
      asset_type = create(:asset_type, name: "Generador")

      expect(asset_type.discard).to be(true)
      expect(asset_type.reload).to be_discarded
    end

    it "does not discard a type assigned to an equipment kind" do
      asset_type = create(:asset_type, name: "a2")
      equipment_kind = create(:equipment_kind, name: "a1", asset_type: asset_type)

      expect(asset_type.discard).to be(false)
      expect(asset_type).not_to be_discarded
      expect(asset_type.errors[:base]).to include("No se puede eliminar porque hay otros equipos asociados.")
      expect(equipment_kind.reload.asset_type).to eq(asset_type)
    end

    it "discards a type whose equipment kind was discarded" do
      asset_type = create(:asset_type, name: "Generador")
      create(:equipment_kind, asset_type: asset_type).discard

      expect(asset_type.discard).to be(true)
      expect(asset_type.reload).to be_discarded
    end
  end
end
