module FieldDefinitionsValidatable
  extend ActiveSupport::Concern

  FIELD_TYPES = %w[string integer float date boolean].freeze

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
end
