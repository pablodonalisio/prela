class ListItem < ApplicationRecord
  belongs_to :list_section

  attr_accessor :source_item_id

  validates :name, presence: true
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def input_key
    source_item_id.presence || id
  end
end
