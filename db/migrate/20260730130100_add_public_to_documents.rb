class AddPublicToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :public, :boolean, null: false, default: true
    change_column_default :documents, :public, from: true, to: false
  end
end
