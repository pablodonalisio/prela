class EquipmentController < ApplicationController
  def new
    @equipment = Equipment.new
  end

  def index
    @equipment = Equipment.all
  end
end
