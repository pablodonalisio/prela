class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
    scope = policy_scope(ServiceOccurrence.filter(service_filter_params))
    @control_panel_services = ServiceOccurrence.control_panel_by_equipment_kind(scope)
  end

  private

  def service_filter_params
    filtered = params.slice(:client_id)

    if params[:service_kind_id].present?
      filtered[:service_kind_id] = params[:service_kind_id]
    elsif params[:kind].present?
      service_kind = ServiceKind.visible.find_by(legacy_key: params[:kind])
      filtered[:service_kind_id] = service_kind.id if service_kind
    end

    filtered
  end
end
