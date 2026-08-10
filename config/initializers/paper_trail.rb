# PaperTrail stores Time/Date in YAML `object_changes`. Psych safe_load needs them permitted.
# See: https://github.com/paper-trail-gem/paper_trail#working-with-rails
Rails.application.config.to_prepare do
  ActiveRecord.yaml_column_permitted_classes |= [
    Symbol,
    Date,
    Time,
    ActiveSupport::TimeWithZone,
    ActiveSupport::TimeZone,
    BigDecimal
  ]
end
