FactoryBot.define do
  factory :table_dropdown do
    sequence(:name) { |n| "Valores #{n}" }

    transient do
      values { ["Opción A", "Opción B"] }
    end

    after(:build) do |dropdown, evaluator|
      next if dropdown.table_dropdown_values.any?

      evaluator.values.each_with_index do |label, index|
        dropdown.table_dropdown_values.build(label: label, position: index)
      end
    end
  end
end
