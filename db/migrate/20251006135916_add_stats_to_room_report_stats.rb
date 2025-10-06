class AddStatsToRoomReportStats < ActiveRecord::Migration[8.0]
  def change
    add_column :room_report_stats, :clean_and_tidy, :string
    add_column :room_report_stats, :ventilated, :string
    add_column :room_report_stats, :free_access_to_panel, :string
    add_column :room_report_stats, :with_access_key, :string
  end
end
