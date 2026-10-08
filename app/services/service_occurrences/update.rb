class ServiceOccurrences::Update
  ALLOWED_TRANSITIONS = {
    "pending" => %w[suspended scheduled completed],
    "suspended" => %w[pending scheduled completed],
    "scheduled" => %w[pending completed]
  }.freeze

  def self.call(occurrence, attrs)
    new(occurrence, attrs).call
  end

  def initialize(occurrence, attrs)
    @occurrence = occurrence
    @attrs = normalize_attrs(attrs)
  end

  def call
    return false unless valid_change?

    if completing?
      complete!
    else
      apply_workflow_update!
    end

    true
  rescue ActiveRecord::RecordInvalid, ArgumentError => error
    occurrence.errors.add(:base, error.message) if occurrence.errors.empty?
    false
  end

  private

  attr_reader :occurrence, :attrs

  def normalize_attrs(raw)
    raw = raw.to_unsafe_h if raw.respond_to?(:to_unsafe_h)
    raw.to_h.with_indifferent_access
  end

  def target_status
    attrs[:status].present? ? attrs[:status].to_s : occurrence.status
  end

  def status_changing?
    attrs[:status].present? && attrs[:status].to_s != occurrence.status
  end

  def completing?
    target_status == "completed" && !occurrence.completed?
  end

  def valid_change?
    if occurrence.completed? && !status_changing?
      return true
    end

    if occurrence.cancelled? && !status_changing?
      return true
    end

    if status_changing?
      return true if ALLOWED_TRANSITIONS.fetch(occurrence.status, []).include?(target_status)

      occurrence.errors.add(:status, :invalid)
      return false
    end

    if date_attr_present?(:due_on) && !occurrence.pending?
      occurrence.errors.add(:due_on, :invalid)
      return false
    end

    true
  end

  def apply_workflow_update!
    if occurrence.completed? && !status_changing?
      update_completed!
      return
    end

    if occurrence.cancelled? && !status_changing?
      occurrence.update!(notes: attrs[:notes]) if attrs.key?(:notes)
      return
    end

    assignment = {}

    if status_changing?
      assignment[:status] = target_status
      if target_status == "scheduled"
        assignment[:planned_on_init] = datetime_value_for(:planned_on_init)
        assignment[:planned_on_finish] = datetime_value_for(:planned_on_finish)
      elsif %w[pending suspended cancelled].include?(target_status)
        assignment[:planned_on_init] = nil
        assignment[:planned_on_finish] = nil
      end
      assignment[:notes] = attrs[:notes] if attrs.key?(:notes)
    else
      assignment[:due_on] = date_value_for(:due_on) if date_attr_present?(:due_on)
      assignment[:planned_on_init] = datetime_value_for(:planned_on_init) if attrs.key?(:planned_on_init)
      assignment[:planned_on_finish] = datetime_value_for(:planned_on_finish) if attrs.key?(:planned_on_finish)
      assignment[:notes] = attrs[:notes] if attrs.key?(:notes)
    end

    occurrence.update!(assignment)
  end

  def update_completed!
    assignment = {}
    if date_attr_present?(:completed_on)
      completed_on = date_value_for(:completed_on)
      raise ArgumentError, "completed_on is required" if completed_on.blank?

      assignment[:completed_on] = completed_on
      assignment[:due_on] = completed_on
    end
    assignment[:notes] = attrs[:notes] if attrs.key?(:notes)

    occurrence.update!(assignment)
    occurrence.document.attach(attrs[:document]) if attrs[:document].present?
  end

  def complete!
    raise ArgumentError, "only open occurrences can be completed" unless occurrence.open?

    completed_on = date_value_for(:completed_on)
    raise ArgumentError, "completed_on is required" if completed_on.blank?

    document = attrs[:document]

    occurrence.transaction do
      occurrence.update!(
        status: :completed,
        completed_on: completed_on,
        due_on: completed_on
      )
      occurrence.document.attach(document) if document.present?

      les = occurrence.location_equipment_service
      if les.recurring?
        les.service_occurrences.create!(
          status: :pending,
          due_on: les.advance(completed_on)
        )
      end
    end
  end

  def date_attr_present?(attr)
    attrs.key?(attr) || attrs.key?("#{attr}(1i)")
  end

  def datetime_value_for(attr)
    value = attrs[attr]
    return nil if value.blank?
    return Time.zone.parse(value) if value.is_a?(String)
    return value.in_time_zone if value.respond_to?(:in_time_zone)

    nil
  rescue ArgumentError, TypeError
    nil
  end

  def date_value_for(attr)
    value = attrs[attr]
    return value.to_date if value.respond_to?(:to_date) && value.present?
    return Date.parse(value) if value.is_a?(String) && value.present?

    year = attrs["#{attr}(1i)"]
    month = attrs["#{attr}(2i)"]
    day = attrs["#{attr}(3i)"]
    return nil if year.blank? || month.blank? || day.blank?

    Date.new(year.to_i, month.to_i, day.to_i)
  rescue ArgumentError, TypeError
    nil
  end
end
