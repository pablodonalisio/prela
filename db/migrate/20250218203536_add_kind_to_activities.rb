class AddKindToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :kind, :string
  end
end
