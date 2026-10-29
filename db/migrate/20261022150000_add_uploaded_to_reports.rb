class AddUploadedToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :uploaded, :boolean, null: false, default: false
  end
end
