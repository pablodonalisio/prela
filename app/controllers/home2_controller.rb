class Home2Controller < ApplicationController
  def index
    @pagy = Pagy.new(count: 120, page: 3)
  end
end
