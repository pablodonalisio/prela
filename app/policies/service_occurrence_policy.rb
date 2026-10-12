class ServiceOccurrencePolicy < ApplicationPolicy
  def show?
    user.admin? || user.technician? || user.client?
  end

  def update?
    user.admin? || (user.client? && user.editor?)
  end

  def edit?
    update?
  end

  def complete?
    update? || user.technician?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.technician?
        scope.for_visible_location_equipments
      elsif user.client?
        scope.for_visible_location_equipments
          .joins(location_equipment_service: {location_equipment: :location})
          .where(locations: {client_id: user.client_id})
      else
        raise Pundit::NotAuthorizedError
      end
    end
  end
end
