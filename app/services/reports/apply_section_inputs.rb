module Reports
  class ApplySectionInputs
    def self.call(report)
      new(report).call
    end

    def initialize(report)
      @report = report
    end

    def call
      return if report.sections_copied_from_template
      return if report.section_inputs.blank?

      report.sections.each do |section|
        values = inputs_for(section.id)
        next if values.nil?

        apply(section, values)
      end
    end

    private

    attr_reader :report

    def apply(section, values)
      case section.kind
      when "text"
        apply_text(section, values)
      when "images"
        apply_images(section, values)
      when "table"
        apply_cells(section, values)
      when "list"
        apply_list(section, values)
      end
    end

    def apply_text(section, values)
      return unless values.key?("body")

      text_section = section.text_section || section.build_text_section
      text_section.body = values["body"]
    end

    def apply_images(section, values)
      image_section = section.image_section || section.build_image_section
      image_section.pending_images = Array(values["images"])
      image_section.removed_image_ids = Array(values["removed_image_ids"])
    end

    def apply_cells(section, values)
      return if section.table_section.blank?

      cells = values["cells"]
      return if cells.blank?

      cells = cells.to_h
      section.table_section.table_cells.each do |cell|
        next if cell.fixed?

        submitted = cells["#{cell.row_index}_#{cell.column_index}"] || cells[:"#{cell.row_index}_#{cell.column_index}"]
        next if submitted.nil?

        cell.value = submitted.to_h.stringify_keys.fetch("value", cell.value)
      end
    end

    def apply_list(section, values)
      return if section.list_section.blank?

      items = values["items"]
      return if items.blank?

      items = items.to_h
      section.list_section.list_items.each do |item|
        submitted = items[item.id.to_s] || items[item.id]
        next if submitted.nil?

        item.checked = ActiveModel::Type::Boolean.new.cast(submitted.to_h.stringify_keys["checked"])
      end
    end

    def inputs_for(section_id)
      raw = report.section_inputs
      values = raw[section_id.to_s] || raw[section_id] || raw[section_id.to_s.to_sym]
      return if values.nil?

      values.to_h.stringify_keys
    end
  end
end
