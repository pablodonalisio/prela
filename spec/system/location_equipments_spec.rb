require "rails_helper"

RSpec.describe "Location equipments", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "lists a location equipment and opens it" do
    equipment = create(:equipment, name: "UPS sala norte")
    create(:location_equipment, equipment: equipment, code: "EQ-100")

    visit location_equipments_path

    expect(page).to have_text("UPS sala norte")
    expect(page).to have_text("Tipo de equipo: #{equipment.equipment_kind.name}")
    expect(page).to have_text("Código: EQ-100")

    click_on "Ver"

    expect(page).to have_text("UPS sala norte")
    expect(page).to have_button("Informes")
  end

  it "creates a location equipment from the modal" do
    client = create(:client, name: "Gea")
    create(:location, name: "Planta Norte", client: client)
    create(:equipment, name: "UPS de prueba", equipment_kind: create(:equipment_kind))

    visit location_equipments_path
    click_on "Agregar"

    expect(page).to have_text("Nuevo Equipo de Sede")

    choose_from_select "Cliente", "Gea"
    choose_from_select "Sede", "Planta Norte"

    equipment_field = find_field(placeholder: "Seleccione un equipo")
    equipment_field.set("UPS de prueba")
    find("li", text: "UPS de prueba").click

    fill_in "Sala", with: "Sala principal"
    fill_in "Código", with: "EQ-NEW"
    click_on "Aceptar"

    expect(page).to have_text("UPS de prueba")
    expect(page).to have_text("Código: EQ-NEW")
    expect(LocationEquipment.find_by(code: "EQ-NEW")).to be_present
  end

  it "shows services after opening the Servicios tab" do
    equipment = create(:equipment, equipment_kind: create(:equipment_kind), name: "Equipo con servicio")
    location_equipment = create(:location_equipment, equipment: equipment, code: "EQ-200")
    service_kind = create(:service_kind, name: "Mantenimiento anual")
    create(:location_equipment_service, location_equipment: location_equipment, service_kind: service_kind)

    visit location_equipment_path(location_equipment)
    click_on "Servicios"

    expect(page).to have_text("Mantenimiento anual")
  end

  it "filters the list from the mobile filter panel" do
    acme = create(:client, name: "Acme")
    beta = create(:client, name: "Beta")
    create(:location_equipment, location: create(:location, client: acme), code: "ACME-1")
    create(:location_equipment, location: create(:location, client: beta), code: "BETA-2")

    visit location_equipments_path
    use_mobile_layout

    click_on "Abrir filtros"
    check "Acme"

    expect(page).to have_text("Código: ACME-1")
    expect(page).to have_no_text("Código: BETA-2")
  ensure
    use_desktop_layout
  end
end
