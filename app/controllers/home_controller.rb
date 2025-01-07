class HomeController < ApplicationController
  def index
    authorize :home, :index?
  end
end
