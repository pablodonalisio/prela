class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.technician?
  end

  def show?
    user.admin? || own_account?
  end

  def update?
    user.admin? || own_account?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope
      elsif user.technician?
        scope.where(id: user.id)
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end

  private

  def own_account?
    user.technician? && record == user
  end
end
