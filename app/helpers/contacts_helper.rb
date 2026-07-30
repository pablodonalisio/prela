module ContactsHelper
  def manager_options_for(client, contact)
    scope = client.contacts.kept
    scope = scope.where.not(id: contact.id) if contact.persisted?
    scope.order(:name)
  end
end
