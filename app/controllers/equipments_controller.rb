class EquipmentsController < ApplicationController
  def index
    @equipments = Equipment.all
  end
end
