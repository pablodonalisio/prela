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
      measurements: {"1739280000" => {name: "Tensión L1", type: "float"}}
    )
    expect(report_template).to be_valid
  end

  it "is not valid with an invalid field type in a section" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensión L1", type: "invalid"}}
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:measurements]).to be_present
  end

  it "is not valid with duplicate field names within a section" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {
        "1739280000" => {name: "Tensión", type: "float"},
        "1739280001" => {name: "Tensión", type: "float"}
      }
    )
    expect(report_template).not_to be_valid
    expect(report_template.errors[:measurements]).to include("El nombre de campo 'Tensión' ya está en uso.")
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
      measurements: {"1739280000" => {name: "Tensión L1", type: "float", optimal_value: "220", units: "V"}}
    )
    expect(report_template).to be_valid
  end

  it "is valid without optimal value and units on measurements" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Tensión L1", type: "float"}}
    )
    expect(report_template).to be_valid
  end

  it "accepts any text for optimal value and units on measurements" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      measurements: {"1739280000" => {name: "Estado", type: "string", optimal_value: "220 ± 5%", units: "V AC"}}
    )
    expect(report_template).to be_valid
  end

  describe "#active_sections" do
    it "returns only sections with field definitions" do
      report_template = ReportTemplate.new(
        name: "Preventivo UPS",
        measurements: {"1739280000" => {name: "Tensión L1", type: "float"}},
        room_specifications: {"1739280001" => {name: "Temperatura", type: "float"}}
      )

      expect(report_template.active_sections).to eq(%w[measurements room_specifications])
    end
  end
end
