class CommentPolicy < ApplicationPolicy
  def show?
    user.admin? || user.client?
  end

  def index?
    user.admin? || user.client?
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
end
