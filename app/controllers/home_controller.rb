class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
    @location_equipments = policy_scope(LocationEquipment)
  end
end
