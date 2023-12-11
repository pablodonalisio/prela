FactoryBot.define do
  factory :equipment do
    kind { "UPS" }
    brand { "APC" }
    model { "Smart-RT 10000" }
    technical_model { "SURT10000XL" }
    kva { 10 }
    manual { "https://www.apc.com/ar/es/product/SURT10000XLT/unidad-smartups-rt-de-apc-10-000-va-y-208v/" }
  end
end
