module Prioritizable
  extend ActiveSupport::Concern

  PRIORITIES = {critical: 0, normal: 1, low: 2}.freeze

  included do
    enum :priority, PRIORITIES, default: :normal

    validates :priority, presence: true
  end

  def priority_label
    I18n.t("activerecord.attributes.service_kind.priorities.#{priority}")
  end

  class_methods do
    def priority_options
      priorities.keys.map do |priority|
        [I18n.t("activerecord.attributes.service_kind.priorities.#{priority}"), priority]
      end
    end
  end
end
