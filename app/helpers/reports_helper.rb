module ReportsHelper
  include LocationEquipmentsHelper

  def format_report_field_value(type, value, units: nil)
    formatted = base_formatted_value(type, value)
    return formatted if units.blank? || formatted == "—"

    "#{formatted} #{units}"
  end

  def template_report_equipment_rows(report)
    location_equipment = report.location_equipment
    equipment = location_equipment.equipment

    rows = [{label: t("activerecord.attributes.equipment.name"), value: equipment.name}]
    if equipment.equipment_kind&.name.present?
      rows << {label: t("reports.template_report.equipment_kind"), value: equipment.equipment_kind.name}
    end
    rows << {label: t("activerecord.attributes.equipment.brand"), value: equipment.brand} if equipment.brand.present?
    rows << {label: t("activerecord.attributes.equipment.model"), value: equipment.model} if equipment.model.present?
    if location_equipment.serial_number.present?
      rows << {label: t("reports.template_report.serial_number"), value: location_equipment.serial_number}
    end
    if location_equipment.condition.present?
      rows << {label: t("reports.template_report.condition"), value: location_equipment.condition}
    end

    rows + template_report_dynamic_rows(report, "equipment_specifications")
  end

  def template_report_location_specification_rows(report)
    template_report_dynamic_rows(report, "location_specifications")
  end

  def template_report_measurement_rows(report)
    template_report_card_rows(report, "measurements")
  end

  def template_report_room_rows(report)
    template_report_card_rows(report, "room_specifications")
  end

  private

  def template_report_card_rows(report, section)
    template = report.report_template
    values = report.field_values_for(section)

    template.fields_for(section).map do |field_key, definition|
      {
        name: definition["name"],
        value: format_report_field_value(definition["type"], values[field_key], units: definition["units"]),
        optimal: definition["optimal_value"],
        units: definition["units"]
      }
    end
  end

  def template_report_dynamic_rows(report, section)
    template = report.report_template
    values = report.field_values_for(section)

    template.fields_for(section).map do |field_key, definition|
      {
        label: definition["name"],
        value: format_report_field_value(definition["type"], values[field_key], units: definition["units"])
      }
    end
  end

  def base_formatted_value(type, value)
    return "—" if value.nil? || (value.respond_to?(:blank?) && value.blank? && value != false)

    case type
    when "boolean"
      ActiveModel::Type::Boolean.new.cast(value) ? "Sí" : "No"
    when "date"
      Date.parse(value.to_s).strftime("%d/%m/%Y")
    else
      value.to_s
    end
  rescue ArgumentError
    value.to_s
  end
end
