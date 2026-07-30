class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  has_one_attached :file

  scope :client_visible, -> { where(public: true) }

  validates :description, :file, presence: true
end
