class AddJobPositionToContacts < ActiveRecord::Migration[7.2]
  def change
    add_column :contacts, :job_position, :string, null: false, default: ""
  end
end
