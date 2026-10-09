require "rails_helper"

RSpec.describe "Asset type dropdown", type: :system do
  let(:admin) { create(:admin) }

  before do
    AssetType.ups
    login_as(admin, scope: :user)
  end

  it "creates and deletes an asset type without leaving the equipment kind modal" do
    visit equipment_kinds_path
    click_link "Agregar", match: :first

    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#asset_type_picker_button", text: "Seleccioná un tipo")

    find("#asset_type_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "UPS")
    expect(page).to have_css("[aria-label='Eliminar UPS']")
    expect(page).to have_css("[aria-label='Editar UPS']")

    click_on "Añadir nuevo tipo..."
    fill_in "Nuevo tipo de activo", with: "Generador"
    find("#asset-type-menu button[type='submit']").click

    expect(page).to have_text("El tipo de activo se creó correctamente.")
    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#asset_type_picker_button", text: "Generador")

    find("#asset_type_picker_button").click
    accept_confirm do
      find("[aria-label='Eliminar Generador']").click
    end

    expect(page).to have_text("El tipo de activo se eliminó.")
    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#asset_type_picker_button", text: "UPS")
  end

  it "clears the add and edit forms when the dropdown closes" do
    create(:asset_type, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first

    find("#asset_type_picker_button").click
    click_on "Añadir nuevo tipo..."
    fill_in "Nuevo tipo de activo", with: "Borrador"
    find("#asset_type_picker_button").click

    find("#asset_type_picker_button").click
    expect(page).to have_button("Añadir nuevo tipo...")
    expect(page).not_to have_field("Nuevo tipo de activo")

    find("[aria-label='Editar Generador']").click
    find("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']").set("Borrador")
    find("#asset_type_picker_button").click

    find("#asset_type_picker_button").click
    expect(page).to have_css("[aria-label='Editar Generador']")
    expect(page).not_to have_css("[data-asset-type-edit-panel]:not(.hidden)")
  end

  it "cancels adding and editing without saving" do
    create(:asset_type, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#asset_type_picker_button").click

    click_on "Añadir nuevo tipo..."
    fill_in "Nuevo tipo de activo", with: "Borrador"
    click_on "Cancelar"
    expect(page).to have_button("Añadir nuevo tipo...")
    expect(page).not_to have_field("Nuevo tipo de activo")

    find("[aria-label='Editar Generador']").click
    find("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']").set("Borrador")
    click_on "Cancelar"
    expect(page).to have_css("[aria-label='Editar Generador']")
    expect(page).not_to have_css("[data-asset-type-edit-panel]:not(.hidden)")
    expect(AssetType.find_by(name: "Borrador")).to be_nil
  end

  it "renames an asset type from the dropdown" do
    create(:asset_type, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#asset_type_picker_button").click
    expect(page).to have_css("[aria-label='Editar UPS']")

    find("[aria-label='Editar Generador']").click
    find("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']").set("Grupo")
    find("[data-asset-type-edit-panel]:not(.hidden) button[type='submit']").click

    expect(page).to have_text("El tipo de activo se actualizó correctamente.")
    expect(page).to have_text("Nuevo Tipo de Equipo")

    find("#asset_type_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "Grupo")
    expect(page).not_to have_text("Generador")
  end

  it "keeps a type that is assigned to an equipment kind" do
    asset_type = create(:asset_type, name: "a2")
    create(:equipment_kind, asset_type: asset_type, name: "a1")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#asset_type_picker_button").click

    accept_confirm do
      find("[aria-label='Eliminar a2']").click
    end

    expect(accept_alert).to eq("No se puede eliminar porque hay otros equipos asociados.")
    expect(page).to have_text("Nuevo Tipo de Equipo")

    find("#asset_type_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "a2")
  end

  it "updates the filter dropdown when an asset type is added, renamed, or deleted" do
    visit equipment_kinds_path

    within("#equipment_kind_filters") do
      find("button[aria-label='Tipo de Activo']").click
      check "UPS"
    end

    click_link "Agregar", match: :first
    find("#asset_type_picker_button").click
    click_on "Añadir nuevo tipo..."
    fill_in "Nuevo tipo de activo", with: "Generador"
    find("#asset-type-menu button[type='submit']").click

    expect(page).to have_text("El tipo de activo se creó correctamente.")
    within("#equipment_kind_filters") do
      expect(page).to have_checked_field("UPS", visible: :all)
      expect(page).to have_unchecked_field("Generador", visible: :all)
    end

    find("#asset_type_picker_button").click
    find("[aria-label='Editar Generador']").click
    find("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']").set("Grupo")
    find("[data-asset-type-edit-panel]:not(.hidden) button[type='submit']").click

    expect(page).to have_text("El tipo de activo se actualizó correctamente.")
    within("#equipment_kind_filters") do
      expect(page).to have_field("Grupo", visible: :all)
      expect(page).to have_no_field("Generador", visible: :all)
    end

    find("#asset_type_picker_button").click
    accept_confirm do
      find("[aria-label='Eliminar Grupo']").click
    end

    expect(page).to have_text("El tipo de activo se eliminó.")
    within("#equipment_kind_filters") do
      expect(page).to have_checked_field("UPS", visible: :all)
      expect(page).to have_no_field("Grupo", visible: :all)
    end
  end

  it "renames and deletes UPS when no equipment uses it" do
    AssetType.ups

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#asset_type_picker_button").click

    find("[aria-label='Editar UPS']").click
    find("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']").set("Respaldo")
    find("[data-asset-type-edit-panel]:not(.hidden) button[type='submit']").click

    expect(page).to have_text("El tipo de activo se actualizó correctamente.")
    find("#asset_type_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "Respaldo")

    accept_confirm do
      find("[aria-label='Eliminar Respaldo']").click
    end

    expect(page).to have_text("El tipo de activo se eliminó.")
    find("#asset_type_picker_button").click
    expect(page).not_to have_css("[role='listbox']", text: "Respaldo")
  end
end
