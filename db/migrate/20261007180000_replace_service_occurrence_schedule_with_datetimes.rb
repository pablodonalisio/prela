class ReplaceServiceOccurrenceScheduleWithDatetimes < ActiveRecord::Migration[8.0]
  def up
    add_column :service_occurrences, :planned_on_init, :datetime
    add_column :service_occurrences, :planned_on_finish, :datetime

    if column_exists?(:service_occurrences, :planned_on)
      if column_exists?(:service_occurrences, :start_time)
        execute <<~SQL.squish
          UPDATE service_occurrences
          SET planned_on_init = planned_on + start_time
          WHERE planned_on IS NOT NULL AND start_time IS NOT NULL
        SQL
      else
        execute <<~SQL.squish
          UPDATE service_occurrences
          SET planned_on_init = planned_on::timestamp
          WHERE planned_on IS NOT NULL
        SQL
      end

      if column_exists?(:service_occurrences, :end_time)
        execute <<~SQL.squish
          UPDATE service_occurrences
          SET planned_on_finish = planned_on + end_time
          WHERE planned_on IS NOT NULL AND end_time IS NOT NULL
        SQL
      end

      remove_column :service_occurrences, :planned_on
    end

    remove_column :service_occurrences, :start_time if column_exists?(:service_occurrences, :start_time)
    remove_column :service_occurrences, :end_time if column_exists?(:service_occurrences, :end_time)
  end

  def down
    add_column :service_occurrences, :planned_on, :date
    add_column :service_occurrences, :start_time, :time
    add_column :service_occurrences, :end_time, :time

    if column_exists?(:service_occurrences, :planned_on_init)
      execute <<~SQL.squish
        UPDATE service_occurrences
        SET planned_on = planned_on_init::date,
            start_time = planned_on_init::time,
            end_time = planned_on_finish::time
        WHERE planned_on_init IS NOT NULL
      SQL
    end

    remove_column :service_occurrences, :planned_on_finish if column_exists?(:service_occurrences, :planned_on_finish)
    remove_column :service_occurrences, :planned_on_init if column_exists?(:service_occurrences, :planned_on_init)
  end
end
