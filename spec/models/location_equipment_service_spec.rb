require "rails_helper"

RSpec.describe LocationEquipmentService, type: :model do
  it "is valid with required attributes" do
    expect(build(:location_equipment_service)).to be_valid
  end

  it "is not valid with a non-positive interval when recurring" do
    expect(build(:location_equipment_service, interval: 0)).not_to be_valid
  end

  it "is valid as one-time without interval fields" do
    service_kind = create(:service_kind, :one_time)
    les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
    expect(les).to be_valid
  end

  it "clears interval fields when the service kind is one-time" do
    service_kind = create(:service_kind, :one_time)
    les = build(:location_equipment_service, service_kind: service_kind, interval: 1, interval_unit: :years)
    expect(les).to be_valid
    expect(les.interval).to be_nil
    expect(les.interval_unit).to be_nil
  end

  it "prefills interval from the service kind when recurring" do
    service_kind = create(:service_kind, default_interval: 3, interval_unit: :months)
    les = LocationEquipmentService.new(
      location_equipment: create(:location_equipment),
      service_kind: service_kind
    )
    expect(les).to be_valid
    expect(les.interval).to eq(3)
    expect(les.interval_unit).to eq("months")
  end

  it "allows any visible service kind on a location equipment" do
    location_equipment = create(:location_equipment)
    foreign_kind = create(:service_kind)
    les = LocationEquipmentService.new(
      location_equipment: location_equipment,
      service_kind: foreign_kind,
      interval: 1,
      interval_unit: :years
    )

    expect(les).to be_valid
  end

  describe "#advance" do
    it "advances by years" do
      les = build(:location_equipment_service, interval: 2, interval_unit: :years)
      expect(les.advance(Date.new(2024, 1, 15)).to_date).to eq(Date.new(2026, 1, 15))
    end

    it "advances by months" do
      les = build(:location_equipment_service, interval: 6, interval_unit: :months)
      expect(les.advance(Date.new(2024, 1, 15)).to_date).to eq(Date.new(2024, 7, 15))
    end

    it "advances by weeks" do
      les = build(:location_equipment_service, interval: 2, interval_unit: :weeks)
      expect(les.advance(Date.new(2024, 1, 1)).to_date).to eq(Date.new(2024, 1, 15))
    end

    it "returns nil for one-time services" do
      service_kind = build(:service_kind, :one_time)
      les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
      expect(les.advance(Date.new(2024, 1, 1))).to be_nil
    end
  end

  describe "#interval_label" do
    it "combines interval and unit" do
      les = build(:location_equipment_service, interval: 3, interval_unit: :months)
      expect(les.interval_label).to eq("3 meses")
    end

    it "returns the one-time label when not recurring" do
      service_kind = build(:service_kind, :one_time)
      les = build(:location_equipment_service, service_kind: service_kind, interval: nil, interval_unit: nil)
      expect(les.interval_label).to eq("Único")
    end
  end
end
