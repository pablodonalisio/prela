class AddStartAndEndTimeToServiceOccurrences < ActiveRecord::Migration[8.0]
  def change
    add_column :service_occurrences, :start_time, :time unless column_exists?(:service_occurrences, :start_time)
    add_column :service_occurrences, :end_time, :time unless column_exists?(:service_occurrences, :end_time)
  end
end
