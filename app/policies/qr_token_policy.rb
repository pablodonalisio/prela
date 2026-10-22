class QrTokenPolicy < ApplicationPolicy
  def show?
    user.admin? || user.technician?
  end
end
