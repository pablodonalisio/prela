class SuppliesController < ApplicationController
  def index
    @batteries = Battery.all
  end
end
