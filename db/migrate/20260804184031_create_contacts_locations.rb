class CreateContactsLocations < ActiveRecord::Migration[7.2]
  def up
    create_table :contacts_locations, id: false do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
    end

    add_index :contacts_locations,
      [:contact_id, :location_id],
      unique: true,
      name: "index_contacts_locations_uniqueness"

    execute <<~SQL.squish
      INSERT INTO contacts_locations (contact_id, location_id)
      SELECT id, location_id FROM contacts WHERE location_id IS NOT NULL
    SQL

    remove_reference :contacts, :location, foreign_key: true
  end

  def down
    add_reference :contacts, :location, null: true, foreign_key: true

    execute <<~SQL.squish
      UPDATE contacts
      SET location_id = contacts_locations.location_id
      FROM contacts_locations
      WHERE contacts.id = contacts_locations.contact_id
        AND contacts.location_id IS NULL
    SQL

    drop_table :contacts_locations
  end
end
