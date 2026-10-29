require "rails_helper"

RSpec.describe TableDropdown, type: :model do
  it "is valid with a name and at least one value" do
    dropdown = build(:table_dropdown, name: "Estado", values: ["Bueno"])
    expect(dropdown).to be_valid
  end

  it "requires a name" do
    dropdown = build(:table_dropdown, name: " ")
    expect(dropdown).not_to be_valid
    expect(dropdown.errors[:name]).to be_present
  end

  it "requires at least one value" do
    dropdown = TableDropdown.new(name: "Estado")
    expect(dropdown).not_to be_valid
    expect(dropdown.errors[:base]).to include("Agregá al menos un valor.")
  end

  it "rejects a duplicate name ignoring case and accents" do
    create(:table_dropdown, name: "Estado general")
    duplicate = build(:table_dropdown, name: "ESTADO GENERAL")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to be_present
  end

  it "hides report copies from the catalog and lets them reuse the name" do
    catalog = create(:table_dropdown, name: "Estado", values: ["Bueno"])
    template = create(:report_template, :with_measurements)
    cell = template.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1)
    cell.update!(value_type: "dropdown", for_metrics: false, fixed: false, table_dropdown: catalog)
    report = create(:report, :template_based, report_template: template)
    copy = report.table_dropdowns.first

    expect(copy.name).to eq("Estado")
    expect(TableDropdown.visible).to contain_exactly(catalog)
  end

  it "reuses a name after the previous set is discarded" do
    original = create(:table_dropdown, name: "Estado")
    original.discard!

    replacement = build(:table_dropdown, name: "Estado")
    expect(replacement).to be_valid
  end

  it "renumbers values and drops blank new rows" do
    dropdown = TableDropdown.create!(
      name: "Estado",
      table_dropdown_values_attributes: {
        "0" => {label: "  Bueno  ", position: 4},
        "1" => {label: " ", position: 1},
        "2" => {label: "Malo", position: 9}
      }
    )

    expect(dropdown.table_dropdown_values.order(:position).map { |value| [value.position, value.label] }).to eq(
      [[0, "Bueno"], [1, "Malo"]]
    )
  end

  it "rejects two values with the same text" do
    dropdown = build(
      :table_dropdown,
      values: ["Bueno", "bueno"]
    )
    expect(dropdown).not_to be_valid
  end

  it "does not discard a set used by a cell" do
    dropdown = create(:table_dropdown)
    template = create(:report_template, :with_measurements)
    cell = template.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1)
    cell.update!(value_type: "dropdown", fixed: false, for_metrics: true, table_dropdown: dropdown)

    expect(dropdown.discard).to be_falsey
    expect(dropdown.reload).not_to be_discarded
    expect(dropdown.errors[:base].join).to include("celdas que lo usan")
  end
end
