module ReportFieldValuesValidatable
  extend ActiveSupport::Concern

  private

  def validate_field_values_match_template
    return unless template_based?
    return if report_template.blank?

    report_template.active_sections.each do |section|
      definitions = report_template.public_send(section)
      values = field_values_for(section)

      definitions.each do |field_key, definition|
        value = values[field_key]
        next if value.blank? && value != false

        validate_field_value_type(section, field_key, definition["type"], value)
      end
    end
  end

  def validate_field_value_type(section, field_key, type, value)
    case type
    when "integer"
      Integer(value)
    when "float"
      Float(value)
    when "boolean"
      return if [true, false, "0", "1", 0, 1, "true", "false"].include?(value)

      raise ArgumentError
    when "date"
      Date.parse(value.to_s)
    end
  rescue ArgumentError, TypeError
    field_name = report_template.public_send(section)[field_key]["name"]
    errors.add(:field_values, "El valor de '#{field_name}' no es válido.")
  end
end
