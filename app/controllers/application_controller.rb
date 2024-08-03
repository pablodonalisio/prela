class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  after_action :verify_authorized

  def after_sign_out_path_for(user)
    new_user_session_path
  end
end
