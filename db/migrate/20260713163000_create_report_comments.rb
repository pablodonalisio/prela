class CreateReportComments < ActiveRecord::Migration[8.0]
  def change
    create_table :report_comments do |t|
      t.references :report, null: false, foreign_key: true
      t.text :description, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :report_comments, [:report_id, :position]
  end
end
