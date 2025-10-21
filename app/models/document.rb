class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  has_one_attached :file

  validates :description, :file, presence: true
end
