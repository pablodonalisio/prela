class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.references :client, null: false, foreign_key: true
      t.references :location, null: true, foreign_key: true
      t.references :reports_to, null: true, foreign_key: {to_table: :contacts}
      t.string :name, null: false
      t.string :work_area, null: false
      t.text :description
      t.string :email
      t.string :phone
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :contacts, :discarded_at
  end
end
