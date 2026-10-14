require "rails_helper"

RSpec.describe "Equipment kinds", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "filters the list by one or more asset types" do
    generator = create(:assets_category, name: "Generador")
    panel = create(:assets_category, name: "Tablero eléctrico")
    create(:equipment_kind, name: "Grupo diesel", assets_category: generator)
    create(:equipment_kind, name: "Tablero principal", assets_category: panel)
    create(:equipment_kind, name: "UPS online")

    visit equipment_kinds_path

    expect(page).to have_text("Grupo diesel")
    expect(page).to have_text("Tablero principal")
    expect(page).to have_text("UPS online")

    within("#equipment_kind_filters") do
      find("button[aria-label='Categoría']").click
      check "Generador"
    end

    expect(page).to have_text("Grupo diesel")
    expect(page).to have_no_text("Tablero principal")
    expect(page).to have_no_text("UPS online")

    within("#equipment_kind_filters") do
      check "Tablero eléctrico"
    end

    expect(page).to have_text("Grupo diesel")
    expect(page).to have_text("Tablero principal")
    expect(page).to have_no_text("UPS online")
    expect(page).to have_button("Categoría", text: "Generador, Tablero eléctrico")
  end
end
