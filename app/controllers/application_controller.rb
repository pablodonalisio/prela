class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_out_path_for(user)
    new_user_session_path
  end

  private

  def user_not_authorized
    flash[:alert] = "No estas autorizado para realizar esta acción."
    redirect_back_or_to(root_path)
  end
end
