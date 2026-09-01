class DropServiceDates < ActiveRecord::Migration[8.0]
  def up
    drop_table :service_dates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
