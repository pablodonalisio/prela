module FieldDefinitionsValidatable
  extend ActiveSupport::Concern

  FIELD_TYPES = %w[string integer float date boolean].freeze
  NUMERIC_FIELD_TYPES = %w[integer float].freeze

  class_methods do
    def generate_field_key
      Time.now.to_i
    end

    def normalize_name(value)
      ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
    end
  end

  private

  def validate_field_definitions(attribute)
    definitions = public_send(attribute)
    return if definitions.nil?

    normalized_names = {}

    definitions.each do |_key, value|
      if value["name"].blank? || value["type"].blank?
        errors.add(attribute, "Los campos deben tener un nombre y un tipo.")
        break
      elsif !FIELD_TYPES.include?(value["type"])
        errors.add(attribute, "El tipo de campo #{value["type"]} no es válido.")
        break
      elsif invalid_optimal_value?(value)
        errors.add(attribute, "El valor óptimo '#{value["optimal_value"]}' no es válido. Usá un número (ej: 220) o un rango (ej: 220-240).")
        break
      else
        normalized = self.class.normalize_name(value["name"])
        if normalized_names[normalized]
          errors.add(attribute, "El nombre de campo '#{value["name"]}' ya está en uso.")
          break
        end

        normalized_names[normalized] = true
      end
    end
  end

  def invalid_optimal_value?(value)
    return false if value["optimal_value"].blank?
    return false unless NUMERIC_FIELD_TYPES.include?(value["type"])

    !Reports::OptimalValueStatus.valid_format?(value["optimal_value"])
  end
end
