module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = where(nil)
      filtering_params.each do |key, value|
        value.compact_blank! if value.respond_to?(:compact_blank!)
        results = results.public_send("by_#{key}", value) if value.present?
      end
      results
    end
  end
end
