class SignaturePolicy < ApplicationPolicy
  def index?
    user.admin? || user.technician?
  end

  def create?
    user.admin? || user.technician?
  end

  def update?
    user.admin? || own_signature?
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope
      elsif user.technician?
        scope.where(user_id: user.id)
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end

  private

  def own_signature?
    user.technician? && record.user_id == user.id
  end
end
