module HomeHelper
  def user_location_equipments
    current_user.admin? ? LocationEquipment.all : current_user.location_equipments
  end
end
