FactoryBot.define do
  factory :equipment do
    kind { "ups" }
    brand { "APC" }
    model { "Smart-RT 10000" }
    technical_model { "SURT10000XL" }
    kva { 10 }
    battery_qty { 16 }
    battery_type { "BP5-1" }
    battery_info { "12v 5ah" }
    manual { "https://www.apc.com/ar/es/product/SURT10000XLT/unidad-smartups-rt-de-apc-10-000-va-y-208v/" }
    details { "Tiene 2 battery pack" }
    serial_number { "lS1051004604" }
  end
end
