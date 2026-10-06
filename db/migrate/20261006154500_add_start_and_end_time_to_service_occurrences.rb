class AddStartAndEndTimeToServiceOccurrences < ActiveRecord::Migration[8.0]
  def up
    add_column :service_occurrences, :start_time, :time unless column_exists?(:service_occurrences, :start_time)
    add_column :service_occurrences, :end_time, :time unless column_exists?(:service_occurrences, :end_time)
  end

  def down
    remove_column :service_occurrences, :end_time if column_exists?(:service_occurrences, :end_time)
    remove_column :service_occurrences, :start_time if column_exists?(:service_occurrences, :start_time)
  end
end
