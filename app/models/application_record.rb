class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.enum_attributes_for_select(attribute)
    send(attribute.pluralize).map do |option, _|
      [I18n.t("activerecord.attributes.#{name.underscore}.#{attribute.pluralize}.#{option}"), option]
    end
  end
end
