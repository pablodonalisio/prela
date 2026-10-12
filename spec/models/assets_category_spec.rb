require "rails_helper"

RSpec.describe AssetsCategory, type: :model do
  it "is valid with a name" do
    expect(AssetsCategory.new(name: "Generador")).to be_valid
  end

  it "is not valid without a name" do
    expect(AssetsCategory.new(name: nil)).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case" do
    AssetsCategory.create!(name: "Generador")
    assets_category = AssetsCategory.new(name: "generador")
    expect(assets_category).not_to be_valid
    expect(assets_category.errors[:name]).to be_present
  end

  describe "#update" do
    it "renames the type" do
      assets_category = create(:assets_category, name: "Generador")

      expect(assets_category.update(name: "Respaldo")).to be(true)
      expect(assets_category.reload.name).to eq("Respaldo")
    end
  end

  describe "#discard" do
    it "discards a type that no equipment kind uses" do
      assets_category = create(:assets_category, name: "Generador")

      expect(assets_category.discard).to be(true)
      expect(assets_category.reload).to be_discarded
    end

    it "does not discard a type assigned to an equipment kind" do
      assets_category = create(:assets_category, name: "a2")
      equipment_kind = create(:equipment_kind, name: "a1", assets_category: assets_category)

      expect(assets_category.discard).to be(false)
      expect(assets_category).not_to be_discarded
      expect(assets_category.errors[:base]).to include("No se puede eliminar porque hay otros equipos asociados.")
      expect(equipment_kind.reload.assets_category).to eq(assets_category)
    end

    it "discards a type whose equipment kind was discarded" do
      assets_category = create(:assets_category, name: "Generador")
      create(:equipment_kind, assets_category: assets_category).discard

      expect(assets_category.discard).to be(true)
      expect(assets_category.reload).to be_discarded
    end
  end
end
