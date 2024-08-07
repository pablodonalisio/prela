class SuppliesController < ApplicationController
  def index
    @batteries = authorize Battery.all
  end
end
