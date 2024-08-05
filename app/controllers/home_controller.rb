class HomeController < ApplicationController
  def index
    redirect_to location_equipments_path

    authorize :home, :index?
  end
end
