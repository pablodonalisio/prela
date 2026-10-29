module Reports
  class CopyTemplateSections
    def self.call(report)
      new(report).call
    end

    def initialize(report)
      @report = report
    end

    def call
      return if report.report_template.blank?
      return if report.sections.any?

      report.report_template.sections.with_details.order(:position).each do |source|
        copy_section(source)
      end
      report.sections_copied_from_template = true
    end

    private

    attr_reader :report

    def copy_section(source)
      copy = report.sections.build(
        title: source.title,
        position: source.position,
        kind: source.kind,
        source_section_id: source.id
      )

      case source.kind
      when "text"
        copy.build_text_section(body: submitted_text_body(source))
      when "images"
        image_section = copy.build_image_section
        image_section.pending_images = Array(inputs_for(source.id)["images"])
      when "table"
        table = copy.build_table_section(
          row_count: source.table_section.row_count,
          column_count: source.table_section.column_count
        )
        source.table_section.table_cells.each do |cell|
          copied = table.table_cells.build(
            row_index: cell.row_index,
            column_index: cell.column_index,
            value_type: cell.value_type,
            value: cell_value(cell, source.id),
            for_metrics: cell.for_metrics,
            fixed: cell.fixed,
            table_dropdown: dropdown_snapshot(cell.table_dropdown)
          )
          cell.table_cell_options.each do |option|
            copied.table_cell_options.build(value: option.value, label: option.label)
          end
        end
        source.table_section.table_labels.each do |label|
          table.table_labels.build(axis: label.axis, position: label.position, label: label.label)
        end
      when "list"
        list = copy.build_list_section
        source.list_section.list_items.each do |item|
          copied = list.list_items.build(
            name: item.name,
            position: item.position,
            checked: checked_item?(source.id, item.id)
          )
          copied.source_item_id = item.id
        end
      end
    end

    def dropdown_snapshot(dropdown)
      return if dropdown.nil?

      @dropdown_snapshots ||= {}
      return @dropdown_snapshots[dropdown.id] if @dropdown_snapshots.key?(dropdown.id)

      copy = report.table_dropdowns.build(name: dropdown.name)
      dropdown.table_dropdown_values.each do |value|
        copy.table_dropdown_values.build(label: value.label, position: value.position)
      end
      @dropdown_snapshots[dropdown.id] = copy
    end

    def submitted_text_body(source)
      values = inputs_for(source.id)
      return unless values.key?("body")

      values["body"]
    end

    def checked_item?(section_id, item_id)
      submitted = inputs_for(section_id).dig("items", item_id.to_s) || inputs_for(section_id).dig("items", item_id)
      return false if submitted.nil?

      ActiveModel::Type::Boolean.new.cast(submitted.to_h.stringify_keys["checked"])
    end

    def cell_value(cell, section_id)
      return cell.value if cell.fixed?

      submitted = inputs_for(section_id).dig("cells", "#{cell.row_index}_#{cell.column_index}")
      return cell.value if submitted.nil?

      submitted.to_h.stringify_keys.fetch("value", cell.value)
    end

    def inputs_for(section_id)
      raw = report.section_inputs
      return {} if raw.blank?

      values = raw[section_id.to_s] || raw[section_id] || raw[section_id.to_s.to_sym]
      return {} if values.nil?

      values.to_h.stringify_keys
    end
  end
end
