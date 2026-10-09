require "rails_helper"

RSpec.describe "Equipment kinds", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "filters the list by one or more asset types" do
    generator = create(:asset_type, name: "Generador")
    panel = create(:asset_type, name: "Tablero eléctrico")
    create(:equipment_kind, name: "Grupo diesel", asset_type: generator)
    create(:equipment_kind, name: "Tablero principal", asset_type: panel)
    create(:equipment_kind, name: "UPS online", asset_type: AssetType.ups)

    visit equipment_kinds_path

    expect(page).to have_text("Grupo diesel")
    expect(page).to have_text("Tablero principal")
    expect(page).to have_text("UPS online")

    within("#equipment_kind_filters") do
      find("button[aria-label='Tipo de Activo']").click
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
    expect(page).to have_button("Tipo de Activo", text: "Generador, Tablero eléctrico")
  end
end
