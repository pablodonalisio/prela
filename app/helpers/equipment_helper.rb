module EquipmentHelper
  def attributes_to_show(equipment)
    equipment.attributes.except(*attributes_to_hide(equipment))
  end

  def attributes_to_hide(equipment)
    attributes = %w[id created_at updated_at]
    attributes += %w[kva] unless equipment.ups?
    attributes += %w[kw motor_brand motor_model generator_brand generator_model] unless equipment.power_unit?

    attributes
  end
end
