class CommentPolicy < ApplicationPolicy
  def show?
    user.admin? || user.technician? || user.client?
  end

  def index?
    user.admin? || user.technician? || user.client?
  end

  def create?
    user.admin? || user.technician?
  end

  def new?
    create?
  end

  def update?
    user.admin? || user.technician?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || user.technician?
  end
end
