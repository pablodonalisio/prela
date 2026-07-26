require "rails_helper"

RSpec.describe ReportTemplate, type: :model do
  it "is valid with a name and empty sections" do
    report_template = ReportTemplate.new(name: "Preventivo UPS")
    expect(report_template).to be_valid
  end

  it "is not valid without a name" do
    report_template = ReportTemplate.new
    expect(report_template).not_to be_valid
  end

  it "is not valid with a duplicate name" do
    ReportTemplate.create!(name: "Preventivo UPS")
    report_template = ReportTemplate.new(name: "Preventivo UPS")
    expect(report_template).not_to be_valid
    expect(report_template.errors[:name]).to be_present
  end

  it "is not valid with a duplicate name ignoring case" do
    ReportTemplate.create!(name: "Preventivo UPS")
    report_template = ReportTemplate.new(name: "PREVENTIVO UPS")
    expect(report_template).not_to be_valid
    expect(report_template.errors[:name]).to be_present
  end

  it "is valid with field definitions in a section" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "float"}}
    )
    expect(report_template).to be_valid
  end

  it "is not valid with an invalid field type in a section" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "invalid"}}
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:measurements]).to be_present
  end

  it "is not valid with duplicate field names within a section" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {
        "1739280000" => {name: "Tensi?n", type: "float"},
        "1739280001" => {name: "Tensi?n", type: "float"}
      }
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:measurements]).to include("El nombre de campo 'Tensi?n' ya est? en uso.")
  end

  it "is valid with the same field name in different sections" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      equipment_specifications: {"1739280000" => {name: "Marca", type: "string"}},
      measurements: {"1739280001" => {name: "Marca", type: "string"}}
    )
    expect(report_template).to be_valid
  end

  it "is valid with optional optimal value and units on measurements" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "float", optimal_value: "220", units: "V"}}
    )
    expect(report_template).to be_valid
  end

  it "is valid with a range optimal value on numeric measurements" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "float", optimal_value: "220-240", units: "V"}}
    )
    expect(report_template).to be_valid
  end

  it "is valid without optimal value and units on measurements" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "float"}}
    )
    expect(report_template).to be_valid
  end

  it "allows free-text optimal values on non-numeric measurement fields" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Estado", type: "string", optimal_value: "Normal", units: nil}}
    )
    expect(report_template).to be_valid
  end

  it "rejects invalid optimal values on numeric measurement fields" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensi?n L1", type: "float", optimal_value: "220 ? 5%", units: "V"}}
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:measurements].first).to include("valor ?ptimo")
  end

  it "is valid with a range optimal value on numeric room specifications" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      room_specifications: {"1739280000" => {name: "Temperatura", type: "float", optimal_value: "20-25", units: "C"}}
    )
    expect(report_template).to be_valid
  end

  it "rejects invalid optimal values on numeric room specification fields" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      room_specifications: {"1739280000" => {name: "Temperatura", type: "float", optimal_value: "20 +/- 5%", units: "C"}}
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:room_specifications].first).to include("no es v")
  end

  describe "#fields_for" do
    it "returns fields sorted by position" do
      report_template = ReportTemplate.new(
        name: "Preventivo UPS",
        measurements: {
          "100" => {name: "Segundo", type: "string", position: 1},
          "200" => {name: "Primero", type: "string", position: 0}
        }
      )

      expect(report_template.fields_for("measurements").keys).to eq(%w[200 100])
    end

    it "preserves hash order for fields without position" do
      report_template = ReportTemplate.new(
        name: "Preventivo UPS",
        measurements: {
          "100" => {name: "Uno", type: "string"},
          "200" => {name: "Dos", type: "string"}
        }
      )

      expect(report_template.fields_for("measurements").keys).to eq(%w[100 200])
    end
  end

  describe "field position normalization" do
    it "assigns sequential positions on save" do
      report_template = ReportTemplate.create!(
        name: "Preventivo UPS",
        measurements: {
          "100" => {name: "Segundo", type: "string", position: 1},
          "200" => {name: "Primero", type: "string", position: 0}
        }
      )

      expect(report_template.measurements["200"]["position"]).to eq(0)
      expect(report_template.measurements["100"]["position"]).to eq(1)
    end
  end

  describe "#active_sections" do
    it "returns only sections with field definitions" do
      report_template = ReportTemplate.new(
        name: "Preventivo UPS",
        measurements: {"1739280000" => {name: "Tensi?n L1", type: "float"}},
        room_specifications: {"1739280001" => {name: "Temperatura", type: "float"}}
      )

      expect(report_template.active_sections).to eq(%w[measurements room_specifications])
    end
  end

  describe "#location_equipments_count" do
    it "returns the number of associated visible location equipments" do
      report_template = create(:report_template, :with_measurements)
      location_equipment = create(:location_equipment)
      discarded_location_equipment = create(:location_equipment)
      discarded_location_equipment.discard
      report_template.location_equipments << location_equipment
      report_template.location_equipments << discarded_location_equipment

      expect(report_template.location_equipments_count).to eq(1)
    end
  end
end

