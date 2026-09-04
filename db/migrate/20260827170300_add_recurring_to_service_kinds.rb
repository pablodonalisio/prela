class AddRecurringToServiceKinds < ActiveRecord::Migration[8.0]
  def change
    add_column :service_kinds, :recurring, :boolean, null: false, default: true

    change_column_null :service_kinds, :default_interval, true
    change_column_default :service_kinds, :default_interval, from: 1, to: nil

    change_column_null :service_kinds, :interval_unit, true
    change_column_default :service_kinds, :interval_unit, from: 0, to: nil

    change_column_null :location_equipment_services, :interval, true
    change_column_default :location_equipment_services, :interval, from: 1, to: nil

    change_column_null :location_equipment_services, :interval_unit, true
    change_column_default :location_equipment_services, :interval_unit, from: 0, to: nil
  end
end
