FactoryBot.define do
  factory :battery do
    model { "BP5-12" }
    voltage { 12 }
    amps { 7 }
  end
end
