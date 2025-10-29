class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
    @overdue_services = policy_scope(ServiceDate.filter(service_filter_params)).overdue_next_service_dates_by_equipment_kind
  end

  private

  def service_filter_params
    params.slice(:kind, :client_id)
  end
end
