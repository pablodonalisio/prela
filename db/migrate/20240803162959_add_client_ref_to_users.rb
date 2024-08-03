class AddClientRefToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :client, foreign_key: true
  end
end
