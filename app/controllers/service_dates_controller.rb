class ServiceDatesController < ApplicationController
  def show
    @service_date = authorize ServiceDate.find(params[:id])
  end
end
