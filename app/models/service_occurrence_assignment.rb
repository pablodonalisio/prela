class ServiceOccurrenceAssignment < ApplicationRecord
  belongs_to :service_occurrence
  belongs_to :user

  validates :user_id, uniqueness: {scope: :service_occurrence_id}
end
