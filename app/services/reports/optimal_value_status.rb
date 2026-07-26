module Reports
  class OptimalValueStatus
    NUMERIC_TYPES = %w[integer float].freeze
    NUMBER_PATTERN = /-?\d+(?:\.\d+)?/
    EXACT_PATTERN = /\A\s*(#{NUMBER_PATTERN.source})\s*\z/
    RANGE_PATTERN = /\A\s*(#{NUMBER_PATTERN.source})\s*[-–—]\s*(#{NUMBER_PATTERN.source})\s*\z/

    def self.call(type:, measured_value:, optimal_value:)
      new(type: type, measured_value: measured_value, optimal_value: optimal_value).status
    end

    def self.valid_format?(optimal_value)
      parse(optimal_value).present?
    end

    def self.parse(optimal_value)
      return if optimal_value.blank?

      text = optimal_value.to_s.strip

      if (match = EXACT_PATTERN.match(text))
        value = Float(match[1])
        return {min: value, max: value}
      end

      if (match = RANGE_PATTERN.match(text))
        min = Float(match[1])
        max = Float(match[2])
        return if min > max

        return {min: min, max: max}
      end

      nil
    rescue ArgumentError, TypeError
      nil
    end

    def initialize(type:, measured_value:, optimal_value:)
      @type = type.to_s
      @measured_value = measured_value
      @optimal_value = optimal_value
    end

    def status
      return if @optimal_value.blank?
      return if measured_blank?

      if NUMERIC_TYPES.include?(@type)
        numeric_status
      elsif @type == "string"
        text_status
      end
    end

    private

    def numeric_status
      range = self.class.parse(@optimal_value)
      return if range.blank?

      measured = Float(@measured_value)
      (measured >= range[:min] && measured <= range[:max]) ? :ok : :not_ok
    rescue ArgumentError, TypeError
      nil
    end

    def text_status
      (@measured_value.to_s.strip.downcase == @optimal_value.to_s.strip.downcase) ? :ok : :not_ok
    end

    def measured_blank?
      @measured_value.nil? || (@measured_value.respond_to?(:blank?) && @measured_value.blank?)
    end
  end
end
