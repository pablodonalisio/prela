class AddReportToTableDropdowns < ActiveRecord::Migration[8.0]
  def up
    add_reference :table_dropdowns, :report, foreign_key: {on_delete: :restrict}
    remove_index :table_dropdowns, name: "index_table_dropdowns_on_normalized_name"
    add_index :table_dropdowns, :normalized_name,
      unique: true,
      where: "(discarded_at IS NULL AND report_id IS NULL)",
      name: "index_table_dropdowns_on_normalized_name"

    snapshot_existing_report_cells
  end

  def down
    snapshot_ids = select_values("SELECT id FROM table_dropdowns WHERE report_id IS NOT NULL")
    if snapshot_ids.any?
      execute <<~SQL.squish
        UPDATE table_cells
        SET table_dropdown_id = NULL
        WHERE table_dropdown_id IN (#{snapshot_ids.join(",")})
      SQL
      execute "DELETE FROM table_dropdowns WHERE report_id IS NOT NULL"
    end

    remove_index :table_dropdowns, name: "index_table_dropdowns_on_normalized_name"
    remove_reference :table_dropdowns, :report, foreign_key: true
    add_index :table_dropdowns, :normalized_name,
      unique: true,
      where: "(discarded_at IS NULL)",
      name: "index_table_dropdowns_on_normalized_name"
  end

  private

  def snapshot_existing_report_cells
    TableDropdown.reset_column_information

    cells = TableCell
      .joins(table_section: :section)
      .where(sections: {sectionable_type: "Report"}, value_type: "dropdown")
      .where.not(table_dropdown_id: nil)
      .includes(:table_dropdown, table_section: :section)

    cells.group_by { |cell| [cell.table_section.section.sectionable_id, cell.table_dropdown_id] }.each_value do |group|
      source = group.first.table_dropdown
      next if source.nil? || source.report_id.present?

      report_id = group.first.table_section.section.sectionable_id
      snapshot = TableDropdown.new(name: source.name, report_id: report_id)
      source.table_dropdown_values.each do |value|
        snapshot.table_dropdown_values.build(label: value.label, position: value.position)
      end
      snapshot.save!
      TableCell.where(id: group.map(&:id)).update_all(table_dropdown_id: snapshot.id)
    end
  end
end
