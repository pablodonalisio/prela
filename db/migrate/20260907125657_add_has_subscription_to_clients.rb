class AddHasSubscriptionToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :has_subscription, :boolean, null: false, default: true
  end
end
