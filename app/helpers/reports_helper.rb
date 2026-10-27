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

    rows
  end

  def template_report_location_rows(report)
    location_equipment = report.location_equipment

    rows = [
      {label: t("reports.template_report.location"), value: location_equipment.location.name},
      {
        label: t("reports.template_report.zone"),
        value: location_equipment.zone.presence || "—"
      },
      {
        label: t("reports.template_report.floor"),
        value: location_equipment.floor.present? ? humanize_floor(location_equipment.floor) : "—"
      }
    ]

    rows
  end

  def template_report_maintenance_rows(report)
    location_equipment = report.location_equipment

    location_equipment.location_equipment_services.includes(:service_kind).order("service_kinds.name").map do |les|
      next_date = les.next_due_on

      {
        name: les.service_kind.name,
        last_date: format_maintenance_date(les.last_completed_on),
        next_date: format_maintenance_date(next_date),
        overdue: maintenance_overdue_label(next_date),
        status: maintenance_overdue_status(next_date)
      }
    end
  end

  def template_report_activity_rows(report)
    report.location_equipment.activities.order(date: :desc).limit(5).map do |activity|
      {
        description: activity.description,
        date: activity.date.strftime("%d/%m/%Y")
      }
    end
  end

  private

  def format_maintenance_date(date)
    return "—" if date.blank?

    I18n.l(date, format: "%B %Y")
  end

  def maintenance_overdue_label(date)
    return "—" if date.blank?

    date < Date.current ? "Sí" : "No"
  end

  def maintenance_overdue_status(date)
    return if date.blank?

    if date < Date.current
      :not_ok
    elsif date < Date.today.months_since(3)
      :warning
    else
      :ok
    end
  end

  def format_table_cell_value(cell)
    if cell.boolean? && (cell.value.present? || cell.value == false)
      cell.option_label(cell.value)
    else
      format_report_field_value(cell.value_type, cell.value)
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
