require "rails_helper"

RSpec.describe ServiceKind, type: :model do
  it "is valid with required attributes" do
    expect(build(:service_kind)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:service_kind, name: nil)).not_to be_valid
  end

  it "is not valid with a non-positive interval" do
    expect(build(:service_kind, default_interval: 0)).not_to be_valid
    expect(build(:service_kind, default_interval: -1)).not_to be_valid
  end

  it "is not valid with a duplicate name" do
    create(:service_kind, name: "Inspección especial")
    expect(build(:service_kind, name: "Inspección especial")).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case and accents" do
    create(:service_kind, name: "Revisión eléctrica")
    service_kind = build(:service_kind, name: "revision electrica")
    expect(service_kind).not_to be_valid
    expect(service_kind.errors[:name]).to be_present
  end

  it "allows reusing a discarded name" do
    discarded = create(:service_kind, name: "Upgrade")
    discarded.discard!
    expect(build(:service_kind, name: "Upgrade")).to be_valid
  end

  it "defaults interval unit to years and priority to normal" do
    service_kind = ServiceKind.create!(name: "Inspección custom", default_interval: 1)
    expect(service_kind.interval_unit).to eq("years")
    expect(service_kind.priority).to eq("normal")
  end

  it "does not allow changing legacy_key after create" do
    service_kind = create(:service_kind, :with_legacy_key)
    expect {
      service_kind.update(legacy_key: "other")
    }.to raise_error(ActiveRecord::ReadonlyAttributeError)
  end

  it "ensures the legacy service kinds" do
    described_class.where.not(legacy_key: nil).delete_all
    described_class.ensure_legacy_kinds!

    expect(described_class.find_by(legacy_key: "battery_change")).to have_attributes(
      default_interval: 2,
      interval_unit: "years",
      priority: "normal"
    )
    expect(described_class.where(legacy_key: described_class::LEGACY_KINDS.map { |k| k[:legacy_key] }).count).to eq(8)
  end

  it "ensures legacy assignments to equipment kinds" do
    ups = EquipmentKind.find_by(legacy_kind: "ups") || create(:equipment_kind, :ups)
    described_class.ensure_legacy_equipment_assignments!

    battery_change = described_class.find_by!(legacy_key: "battery_change")
    expect(ups.service_kinds).to include(battery_change)
    expect(battery_change.equipment_kinds).to include(ups)
  end

  it "can belong to many equipment kinds" do
    service_kind = create(:service_kind)
    ups = create(:equipment_kind, :ups)
    panel = create(:equipment_kind, :electrical_panel)

    service_kind.equipment_kinds << [ups, panel]

    expect(service_kind.equipment_kinds).to contain_exactly(ups, panel)
  end

  describe ".normalize_name" do
    it "downcases, strips, and removes accents" do
      expect(described_class.normalize_name("  Apto Eléctrico  ")).to eq("apto electrico")
    end
  end

  describe "#interval_label" do
    it "combines interval and unit" do
      service_kind = build(:service_kind, default_interval: 2, interval_unit: :years)
      expect(service_kind.interval_label).to eq("2 años")
    end
  end

  describe "#priority_label" do
    it "returns the Spanish label" do
      expect(build(:service_kind, priority: :critical).priority_label).to eq("Crítico")
      expect(build(:service_kind, priority: :low).priority_label).to eq("Baja")
    end
  end

  describe "discard" do
    it "hides discarded records from visible" do
      service_kind = create(:service_kind)
      service_kind.discard!
      expect(ServiceKind.visible).not_to include(service_kind)
    end
  end
end
