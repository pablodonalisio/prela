class EquipmentKind::SyncFieldValues
  def self.call(equipment_kind)
    new(equipment_kind).call
  end

  def initialize(equipment_kind)
    @equipment_kind = equipment_kind
  end

  def call
    if @equipment_kind.saved_change_to_generic_fields?
      old_defs, new_defs = @equipment_kind.saved_change_to_generic_fields
      sync_records(@equipment_kind.equipments, old_defs, new_defs)
    end

    if @equipment_kind.saved_change_to_specific_fields?
      old_defs, new_defs = @equipment_kind.saved_change_to_specific_fields
      records = LocationEquipment.joins(:equipment).where(equipment: {equipment_kind_id: @equipment_kind.id})
      sync_records(records, old_defs, new_defs)
    end
  end

  private

  def sync_records(records, old_defs, new_defs)
    old_defs ||= {}
    new_defs ||= {}

    (old_defs.keys - new_defs.keys).each do |field_key|
      remove_field_values(records, field_key)
    end
  end

  def remove_field_values(records, field_key)
    records.find_each do |record|
      next unless record.field_values.key?(field_key)

      record.update_column(:field_values, record.field_values.except(field_key))
    end
  end
end
