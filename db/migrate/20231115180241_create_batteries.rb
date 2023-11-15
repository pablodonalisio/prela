class CreateBatteries < ActiveRecord::Migration[7.1]
  def change
    create_table :batteries do |t|
      t.string :model
      t.float :voltage
      t.float :amps

      t.timestamps
    end
  end
end
