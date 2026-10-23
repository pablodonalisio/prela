class Section < ApplicationRecord
  SECTIONABLE_TYPES = %w[Report ReportTemplate].freeze

  belongs_to :sectionable, polymorphic: true

  enum :kind, {text: 0, images: 1, table: 2, list: 3}, default: :text, validate: true, scopes: false

  has_one :text_section, dependent: :destroy, autosave: true, inverse_of: :section
  has_one :image_section, dependent: :destroy, autosave: true, inverse_of: :section
  has_one :table_section, dependent: :destroy, autosave: true, inverse_of: :section
  has_one :list_section, dependent: :destroy, autosave: true, inverse_of: :section

  accepts_nested_attributes_for :text_section, :image_section, :table_section, :list_section, allow_destroy: true

  attr_accessor :source_section_id

  validates :title, presence: true
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :sectionable_type, inclusion: {in: SECTIONABLE_TYPES}

  before_validation :sync_kind_detail

  scope :with_details, -> {
    includes(
      :text_section,
      {image_section: {images_attachments: :blob}},
      {table_section: [:table_labels, {table_cells: :table_cell_options}]},
      {list_section: :list_items}
    )
  }

  def input_key
    source_section_id.presence || id
  end

  def owned_by_template?
    sectionable_type == "ReportTemplate"
  end

  private

  def sync_kind_detail
    return if kind.blank? || marked_for_destruction?

    keeper = detail_name_for(kind)
    return if keeper.blank?

    %i[text_section image_section table_section list_section].each do |detail|
      record = public_send(detail)
      next if record.nil? || detail == keeper

      record.mark_for_destruction
    end

    kept = public_send(keeper)
    return if kept.present? && !kept.marked_for_destruction?

    case keeper
    when :text_section
      build_text_section
    when :image_section
      build_image_section
    when :table_section
      build_table_section(row_count: 1, column_count: 1)
    when :list_section
      build_list_section
    end
  end

  def detail_name_for(key)
    {
      "text" => :text_section,
      "images" => :image_section,
      "table" => :table_section,
      "list" => :list_section
    }[key]
  end
end
