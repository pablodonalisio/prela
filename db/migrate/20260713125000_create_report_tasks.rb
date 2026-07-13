class CreateReportTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :report_template_tasks do |t|
      t.references :report_template, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :report_tasks do |t|
      t.references :report, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :completed, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :report_template_tasks, [:report_template_id, :position]
    add_index :report_tasks, [:report_id, :position]
  end
end
