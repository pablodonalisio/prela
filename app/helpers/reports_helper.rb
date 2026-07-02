module ReportsHelper
  def format_report_field_value(type, value)
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
