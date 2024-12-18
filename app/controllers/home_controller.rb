class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all
  end
end
