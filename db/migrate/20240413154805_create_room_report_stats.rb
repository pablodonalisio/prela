class CreateRoomReportStats < ActiveRecord::Migration[7.1]
  def change
    create_table :room_report_stats do |t|
      t.references :report, null: false, foreign_key: true
      t.string :room_status
      t.string :air_conditioning

      t.timestamps
    end
  end
end
