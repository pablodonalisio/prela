class AgendaPolicy < ApplicationPolicy
  def index?
    user.admin? || user.technician? || user.client?
  end

  class Scope < ApplicationPolicy::Scope
  end
end
