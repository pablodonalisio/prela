class HomeController < ApplicationController
  def index
    authorize :home, :index?
    @links = Link.all if current_user.admin?
  end
end
