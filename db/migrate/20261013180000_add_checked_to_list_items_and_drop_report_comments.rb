class AddCheckedToListItemsAndDropReportComments < ActiveRecord::Migration[8.0]
  def change
    add_column :list_items, :checked, :boolean, null: false, default: false
    drop_table :report_comments
  end
end
