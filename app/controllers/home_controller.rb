class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
    @overdue_services = policy_scope(ServiceDate).overdue_next_service_dates_by_equipment_kind
  end
end
