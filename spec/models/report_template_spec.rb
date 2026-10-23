require "rails_helper"

RSpec.describe ReportTemplate, type: :model do
  it "is valid with a name and no sections" do
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

  it "does not save when a section has no title" do
    report_template = ReportTemplate.new(
      name: "Preventivo UPS",
      sections_attributes: {
        "0" => {title: " ", position: 0, kind: "text"}
      }
    )

    expect(report_template).not_to be_valid
    expect(report_template.sections.first.errors[:title]).to be_present
    expect { report_template.save }.not_to change(ReportTemplate, :count)
  end

  it "does not save when a table row or column header is blank" do
    report_template = ReportTemplate.new(
      name: "Mediciones",
      sections_attributes: {
        "0" => {
          title: "Tabla",
          position: 0,
          kind: "table",
          table_section_attributes: {
            row_count: 1,
            column_count: 1,
            table_labels_attributes: {
              "0" => {axis: "column", position: 0, label: " "},
              "1" => {axis: "row", position: 0, label: "Fila 1"}
            }
          }
        }
      }
    )

    expect(report_template).not_to be_valid
    expect(report_template.sections.first.table_section.errors[:base]).to be_present
    expect { report_template.save }.not_to change(ReportTemplate, :count)
  end

  it "does not clear the title of an existing section" do
    report_template = create(:report_template, :with_measurements)
    section = report_template.sections.find_by!(title: "Notas")

    expect(report_template.update(sections_attributes: {"0" => {id: section.id, title: ""}})).to be false
    expect(section.reload.title).to eq("Notas")
  end

  it "saves ordered sections" do
    report_template = ReportTemplate.create!(
      name: "Preventivo UPS",
      sections_attributes: {
        "0" => {title: "Segundo", position: 1, kind: "text", text_section_attributes: {body: "B"}},
        "1" => {title: "Primero", position: 0, kind: "text", text_section_attributes: {body: "A"}}
      }
    )

    expect(report_template.sections.order(:position).map(&:title)).to eq(%w[Primero Segundo])
    expect(report_template.sections.order(:position).map(&:position)).to eq([0, 1])
  end

  it "builds table cells for the declared grid" do
    report_template = ReportTemplate.create!(
      name: "Preventivo UPS",
      sections_attributes: {
        "0" => {
          title: "Mediciones",
          position: 0,
          kind: "table",
          table_section_attributes: {
            row_count: 2,
            column_count: 2,
            table_labels_attributes: {
              "0" => {axis: "column", position: 0, label: "C1"},
              "1" => {axis: "column", position: 1, label: "C2"},
              "2" => {axis: "row", position: 0, label: "F1"},
              "3" => {axis: "row", position: 1, label: "F2"}
            },
            table_cells_attributes: {
              "0" => {row_index: 0, column_index: 0, value_type: "string", value: "L1", fixed: true},
              "1" => {row_index: 0, column_index: 1, value_type: "float", value: "220", for_metrics: true}
            }
          }
        }
      }
    )

    table = report_template.sections.first.table_section
    cells = table.table_cells
    expect(cells.size).to eq(4)
    expect(cells.find_by!(row_index: 0, column_index: 0)).to be_fixed
    expect(cells.find_by!(row_index: 0, column_index: 0).value).to eq("L1")
    expect(cells.find_by!(row_index: 0, column_index: 1)).to be_for_metrics
    expect(cells.find_by!(row_index: 0, column_index: 1).value).to be_nil
    expect(table.table_labels.where(axis: "row").count).to eq(2)
    expect(table.table_labels.where(axis: "column").count).to eq(2)
    expect(table.table_labels.find_by!(axis: "corner", position: 0).label).to eq("")
  end

  it "drops labels that fall outside a smaller grid" do
    report_template = create(:report_template, :with_measurements)
    table = report_template.sections.find_by!(title: "Tensión L1").table_section

    expect(table.update(column_count: 1)).to be true

    positions = table.table_labels.reload.map { |label| [label.axis, label.position] }
    expect(positions).to contain_exactly(["column", 0], ["row", 0], ["corner", 0])
    expect(table.table_labels.find_by!(axis: "column", position: 0).label).to eq("Fase")
    expect(table.table_labels.find_by!(axis: "corner", position: 0).label).to eq("Concepto")
  end

  it "keeps a fixed value and metrics from being selected together" do
    cell = TableCell.new(value_type: "float", row_index: 0, column_index: 0)

    cell.choice = "fixed"
    expect(cell).to be_fixed
    expect(cell).not_to be_for_metrics

    cell.choice = "metrics"
    expect(cell).to be_for_metrics
    expect(cell).not_to be_fixed
  end

  it "saves both boolean option labels and drops them when the type changes" do
    report_template = ReportTemplate.create!(
      name: "Estados",
      sections_attributes: {
        "0" => {
          title: "Resultado",
          position: 0,
          kind: "table",
          table_section_attributes: {
            row_count: 1,
            column_count: 1,
            table_labels_attributes: {
              "0" => {axis: "column", position: 0, label: "Estado"},
              "1" => {axis: "row", position: 0, label: "Resultado"}
            },
            table_cells_attributes: {
              "0" => {
                row_index: 0,
                column_index: 0,
                value_type: "boolean",
                table_cell_options_attributes: {
                  "true" => {value: true, label: "Aprobado"},
                  "false" => {value: false, label: "Rechazado"}
                }
              }
            }
          }
        }
      }
    )

    cell = report_template.sections.first.table_section.table_cells.first
    expect(cell.table_cell_options.count).to eq(2)
    expect(cell.option_label(true)).to eq("Aprobado")
    expect(cell.option_label(false)).to eq("Rechazado")

    expect(cell.update(value_type: "string")).to be true
    expect(cell.table_cell_options.reload).to be_empty
  end

  it "rejects a fixed value on a date or boolean cell" do
    date_cell = TableCell.new(value_type: "date", fixed: true, row_index: 0, column_index: 0)
    boolean_cell = TableCell.new(value_type: "boolean", fixed: true, row_index: 0, column_index: 0)

    expect(date_cell).not_to be_valid
    expect(date_cell.errors[:fixed]).to be_present
    expect(boolean_cell).not_to be_valid
    expect(boolean_cell.errors[:fixed]).to be_present
  end

  it "rejects metrics on a non numeric cell" do
    cell = TableCell.new(value_type: "string", for_metrics: true, row_index: 0, column_index: 0)
    expect(cell).not_to be_valid
    expect(cell.errors[:for_metrics]).to be_present
  end

  it "rejects a cell value that does not match its type" do
    cell = TableCell.new(value_type: "float", value: "no-es-numero", row_index: 0, column_index: 0)
    expect(cell).not_to be_valid
    expect(cell.errors[:value]).to be_present
  end

  it "accepts a decimal cell value written with a comma" do
    cell = TableCell.new(value_type: "float", value: "22,2", fixed: true, row_index: 0, column_index: 0)

    cell.validate

    expect(cell.errors[:value]).to be_empty
    expect(cell.value).to eq("22.2")
  end

  it "rejects a grid larger than the row limit" do
    table = TableSection.new(row_count: TableSection::MAX_ROWS + 1, column_count: 1)
    expect(table).not_to be_valid
    expect(table.errors[:row_count]).to be_present
  end

  it "rejects a grid larger than the column limit" do
    table = TableSection.new(row_count: 1, column_count: TableSection::MAX_COLUMNS + 1)
    expect(table).not_to be_valid
    expect(table.errors[:column_count]).to be_present
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

  describe "destroy" do
    it "deletes the template and keeps the generated report" do
      report = create(:report, :template_based)
      template = report.report_template

      expect { template.destroy! }.to change(ReportTemplate, :count).by(-1)
      expect(report.reload.report_template).to be_nil
      expect(report).to be_template_based
      expect(report.sections.map(&:title)).to include("Tensión L1")
    end
  end
end
