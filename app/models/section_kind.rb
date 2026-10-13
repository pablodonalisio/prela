class SectionKind < ApplicationRecord
  KEYS = {
    "text" => "Texto",
    "images" => "Imágenes",
    "table" => "Tabla",
    "list" => "Listado"
  }.freeze

  has_many :sections, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true, inclusion: {in: KEYS.keys}
  validates :name, presence: true

  def self.seed!
    KEYS.each do |key, name|
      kind = find_or_initialize_by(key: key)
      kind.name = name
      kind.save!
    end
  end

  def self.fetch(key)
    find_by!(key: key)
  end
end
