class ReportTemplatePolicy < ApplicationPolicy
  def index?
    user.admin? || user.technician?
  end

  def show?
    index?
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.technician?
        scope.all
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end
end
