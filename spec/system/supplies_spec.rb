require "rails_helper"

RSpec.describe "Supplies", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "searches cross references and removes a selected one" do
    oil_kind = create(:supply_kind, name: "Aceite")
    battery_kind = create(:supply_kind, name: "Batería")
    create(:supply, name: "Aceite hidráulico ISO 68", supply_kind: oil_kind)
    create(:supply, name: "BP5-12", supply_kind: battery_kind)

    visit supplies_path
    click_on "Agregar"

    expect(page).to have_text("Nuevo insumo")

    within("#remote_modal") do
      find("label", exact_text: "Tipo").find(:xpath, "..").find("button[aria-haspopup='listbox']").click
    end
    find("[role='listbox'] button", exact_text: "Aceite").click

    within("#remote_modal") do
      fill_in "Nombre", with: "Aceite equivalente"

      click_button "Buscar"
      expect(page).to have_select("Filtrar por tipo", selected: "Aceite")
      expect(page).to have_field("Aceite hidráulico ISO 68")
      expect(page).to have_no_field("BP5-12")

      select "Todos", from: "Filtrar por tipo"
      expect(page).to have_field("BP5-12")

      select "Batería", from: "Filtrar por tipo"
      expect(page).to have_field("BP5-12")
      expect(page).to have_no_field("Aceite hidráulico ISO 68")

      select "Aceite", from: "Filtrar por tipo"
      fill_in "Buscar insumo", with: "iso 68"
      expect(page).to have_field("Aceite hidráulico ISO 68")
      expect(page).to have_no_field("BP5-12")

      check "Aceite hidráulico ISO 68"
      expect(page).to have_button("Quitar Aceite hidráulico ISO 68")

      click_button "Quitar Aceite hidráulico ISO 68"
      expect(page).to have_no_button("Quitar Aceite hidráulico ISO 68")

      click_button "Buscar" unless page.has_field?("Aceite hidráulico ISO 68", wait: 0)
      expect(page).to have_unchecked_field("Aceite hidráulico ISO 68")
      check "Aceite hidráulico ISO 68"
      click_on "Aceptar"
    end

    expect(page).to have_text("Referencias cruzadas: Aceite hidráulico ISO 68")
  end
end
