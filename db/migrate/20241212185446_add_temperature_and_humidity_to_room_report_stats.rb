class AddTemperatureAndHumidityToRoomReportStats < ActiveRecord::Migration[7.1]
  def change
    add_column :room_report_stats, :temperature, :float
    add_column :room_report_stats, :humidity, :float
  end
end
