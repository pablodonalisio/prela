class AddDateToReports < ActiveRecord::Migration[7.1]
  def up
    add_column :reports, :date, :datetime
    execute <<-SQL.squish
      UPDATE reports SET date = created_at
    SQL
  end

  def down
    remove_column :reports, :date
  end
end
