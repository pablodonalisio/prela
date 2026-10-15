require "rails_helper"

RSpec.describe "Asset type dropdown", type: :system do
  let(:admin) { create(:admin) }

  before do
    create(:assets_category, name: "Tablero")
    login_as(admin, scope: :user)
  end

  it "creates and deletes an asset type without leaving the equipment kind modal" do
    visit equipment_kinds_path
    click_link "Agregar", match: :first

    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#assets_category_picker_button", text: "Seleccioná una categoría")

    find("#assets_category_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "Tablero")
    expect(page).to have_css("[aria-label='Eliminar Tablero']")
    expect(page).to have_css("[aria-label='Editar Tablero']")

    click_on "Añadir nueva categoría..."
    fill_in "Nueva categoría", with: "Generador"
    find("#assets-category-menu button[type='submit']").click

    expect(page).to have_text("La categoría se creó correctamente.")
    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#assets_category_picker_button", text: "Generador")

    find("#assets_category_picker_button").click
    accept_confirm do
      find("[aria-label='Eliminar Generador']").click
    end

    expect(page).to have_text("La categoría se eliminó.")
    expect(page).to have_text("Nuevo Tipo de Equipo")
    expect(page).to have_css("#assets_category_picker_button", text: "Seleccioná una categoría")

    find("#assets_category_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "Tablero")
    expect(page).to have_no_text("Generador")
  end

  it "clears the add and edit forms when the dropdown closes" do
    create(:assets_category, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first

    find("#assets_category_picker_button").click
    click_on "Añadir nueva categoría..."
    fill_in "Nueva categoría", with: "Borrador"
    find("#assets_category_picker_button").click

    find("#assets_category_picker_button").click
    expect(page).to have_button("Añadir nueva categoría...")
    expect(page).not_to have_field("Nueva categoría")

    find("[aria-label='Editar Generador']").click
    find("[data-assets-category-edit-panel]:not(.hidden) input[name='assets_category[name]']").set("Borrador")
    find("#assets_category_picker_button").click

    find("#assets_category_picker_button").click
    expect(page).to have_css("[aria-label='Editar Generador']")
    expect(page).not_to have_css("[data-assets-category-edit-panel]:not(.hidden)")
  end

  it "cancels adding and editing without saving" do
    create(:assets_category, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#assets_category_picker_button").click

    click_on "Añadir nueva categoría..."
    fill_in "Nueva categoría", with: "Borrador"
    click_on "Cancelar"
    expect(page).to have_button("Añadir nueva categoría...")
    expect(page).not_to have_field("Nueva categoría")

    find("[aria-label='Editar Generador']").click
    find("[data-assets-category-edit-panel]:not(.hidden) input[name='assets_category[name]']").set("Borrador")
    click_on "Cancelar"
    expect(page).to have_css("[aria-label='Editar Generador']")
    expect(page).not_to have_css("[data-assets-category-edit-panel]:not(.hidden)")
    expect(AssetsCategory.find_by(name: "Borrador")).to be_nil
  end

  it "renames an asset type from the dropdown" do
    create(:assets_category, name: "Generador")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#assets_category_picker_button").click
    expect(page).to have_css("[aria-label='Editar Tablero']")

    find("[aria-label='Editar Generador']").click
    find("[data-assets-category-edit-panel]:not(.hidden) input[name='assets_category[name]']").set("Grupo")
    find("[data-assets-category-edit-panel]:not(.hidden) button[type='submit']").click

    expect(page).to have_text("La categoría se actualizó correctamente.")
    expect(page).to have_text("Nuevo Tipo de Equipo")

    find("#assets_category_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "Grupo")
    expect(page).not_to have_text("Generador")
  end

  it "keeps a type that is assigned to an equipment kind" do
    assets_category = create(:assets_category, name: "a2")
    create(:equipment_kind, assets_category: assets_category, name: "a1")

    visit equipment_kinds_path
    click_link "Agregar", match: :first
    find("#assets_category_picker_button").click

    accept_confirm do
      find("[aria-label='Eliminar a2']").click
    end

    expect(accept_alert).to eq("No se puede eliminar porque hay otros equipos asociados.")
    expect(page).to have_text("Nuevo Tipo de Equipo")

    find("#assets_category_picker_button").click
    expect(page).to have_css("[role='listbox']", text: "a2")
  end

  it "updates the filter dropdown when an asset type is added, renamed, or deleted" do
    visit equipment_kinds_path

    within("#equipment_kind_filters") do
      find("button[aria-label='Categoría']").click
      check "Tablero"
    end

    click_link "Agregar", match: :first
    find("#assets_category_picker_button").click
    click_on "Añadir nueva categoría..."
    fill_in "Nueva categoría", with: "Generador"
    find("#assets-category-menu button[type='submit']").click

    expect(page).to have_text("La categoría se creó correctamente.")
    within("#equipment_kind_filters") do
      expect(page).to have_checked_field("Tablero", visible: :all)
      expect(page).to have_unchecked_field("Generador", visible: :all)
    end

    find("#assets_category_picker_button").click
    find("[aria-label='Editar Generador']").click
    find("[data-assets-category-edit-panel]:not(.hidden) input[name='assets_category[name]']").set("Grupo")
    find("[data-assets-category-edit-panel]:not(.hidden) button[type='submit']").click

    expect(page).to have_text("La categoría se actualizó correctamente.")
    within("#equipment_kind_filters") do
      expect(page).to have_field("Grupo", visible: :all)
      expect(page).to have_no_field("Generador", visible: :all)
    end

    find("#assets_category_picker_button").click
    accept_confirm do
      find("[aria-label='Eliminar Grupo']").click
    end

    expect(page).to have_text("La categoría se eliminó.")
    within("#equipment_kind_filters") do
      expect(page).to have_checked_field("Tablero", visible: :all)
      expect(page).to have_no_field("Grupo", visible: :all)
    end
  end

end
