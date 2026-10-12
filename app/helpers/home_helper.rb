module HomeHelper
  def user_location_equipments
    scope = LocationEquipment.visible
    (current_user.admin? || current_user.technician?) ? scope : scope.by_client_ids([current_user.client_id])
  end
end
