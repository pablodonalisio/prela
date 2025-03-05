class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
    @overdue_ups = policy_scope(LocationEquipment).with_overdue_maintenance(:ups)
    @overdue_power_units = policy_scope(LocationEquipment).with_overdue_maintenance(:power_unit)
  end
end
