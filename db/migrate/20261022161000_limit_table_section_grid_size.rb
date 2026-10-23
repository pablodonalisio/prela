class LimitTableSectionGridSize < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :table_sections,
      "row_count BETWEEN 1 AND 16 AND column_count BETWEEN 1 AND 12",
      name: "table_sections_grid_size"
  end
end
