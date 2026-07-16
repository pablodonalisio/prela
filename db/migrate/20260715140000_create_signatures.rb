class CreateSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :signatures do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :signatures, :discarded_at

    create_table :reports_signatures, id: false do |t|
      t.references :report, null: false, foreign_key: true
      t.references :signature, null: false, foreign_key: true
    end

    add_index :reports_signatures,
      [:report_id, :signature_id],
      unique: true,
      name: "index_reports_signatures_uniqueness"
  end
end
