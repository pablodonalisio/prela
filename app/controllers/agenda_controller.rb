class AgendaController < ApplicationController
  def index
    authorize :agenda, :index?

    @from = parse_date(params[:from]) || default_from
    @to = parse_date(params[:to]) || (Date.current + 90)

    scope = policy_scope(ServiceOccurrence.filter(service_filter_params))
    agenda = scope.for_agenda(@from..@to)
      .includes(
        :technicians,
        location_equipment_service: {
          location_equipment: [:equipment, {location: :client}],
          service_kind: []
      })
    @pagy, @agenda_services = pagy(agenda)
  end

  private

  def default_from
    policy_scope(ServiceOccurrence).earliest_pending_or_scheduled_on || Date.current
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def service_filter_params
    filtered = params.slice(:client_id)

    if params[:service_kind_id].present?
      filtered[:service_kind_id] = params[:service_kind_id]
    end

    if ServiceOccurrence.priorities.key?(params[:priority])
      filtered[:priority] = params[:priority]
    end

    filtered
  end
end
