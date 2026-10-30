class DropBatteries < ActiveRecord::Migration[8.0]
  def up
    blob_ids = ActiveStorage::Attachment.where(record_type: "Battery").pluck(:blob_id)
    ActiveStorage::Attachment.where(record_type: "Battery").delete_all
    ActiveStorage::Blob.where(id: blob_ids).find_each(&:purge)
    drop_table :batteries
  end

  def down
    create_table :batteries do |t|
      t.string :model
      t.float :voltage
      t.float :amps

      t.timestamps
    end
  end
end
