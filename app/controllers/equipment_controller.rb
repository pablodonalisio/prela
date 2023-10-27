class EquipmentController < ApplicationController
  def index
    @equipment = Equipment.all
  end
end
