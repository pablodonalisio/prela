class LocationEquipment
  class ActiveDuration
    SECONDS_PER_YEAR = 1.year.to_f

    def initialize(location_equipment, from: nil, to: Time.current)
      @location_equipment = location_equipment
      @from = from || location_equipment.failure_metrics_start_at
      @to = to
    end

    def seconds
      return 0 if @to <= @from

      status = initial_status
      cursor = @from
      total = 0.0

      status_events.select { |event| event[:at] > @from && event[:at] < @to }.each do |event|
        total += event[:at] - cursor if active?(status)
        status = event[:to]
        cursor = event[:at]
      end

      total += @to - cursor if active?(status)
      total
    end

    def years
      seconds / SECONDS_PER_YEAR
    end

    private

    def active?(status)
      status.to_s == "active"
    end

    def initial_status
      at_or_before = status_events.select { |event| event[:at] <= @from }.last
      return at_or_before[:to] if at_or_before

      # Create versions can be a few ms after created_at (metrics start for new equipment).
      soon = status_events.find { |event| event[:at] > @from && event[:at] <= @from + 5.seconds }
      return soon[:to] if soon && soon[:from].nil?
      return normalize(soon[:from]) if soon && !soon[:from].nil?

      @location_equipment.status
    end

    def status_events
      @status_events ||= @location_equipment.versions.order(:created_at, :id).filter_map do |version|
        change = version.changeset["status"]
        next unless change

        {
          at: version.created_at,
          from: normalize(change.first),
          to: normalize(change.last)
        }
      end
    end

    def normalize(value)
      return if value.nil?

      case value
      when String
        value
      when Integer
        LocationEquipment.statuses.key(value)
      else
        value.to_s
      end
    end
  end
end
