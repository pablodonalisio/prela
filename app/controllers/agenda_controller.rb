class AgendaController < ApplicationController
  def index
    authorize :agenda, :index?

    @from = parse_date(params[:from]) || Date.current.beginning_of_week
    @to = parse_date(params[:to]) || (@from + 4.weeks).end_of_week

    scope = policy_scope(ServiceOccurrence.filter(service_filter_params))
    @agenda_services = scope.for_agenda(@from..@to)
      .includes(location_equipment_service: {
        location_equipment: [:equipment, {location: :client}],
        service_kind: []
      })
  end

  private

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

    filtered
  end
end
