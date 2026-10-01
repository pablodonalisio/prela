require "rails_helper"

RSpec.describe "Reports", type: :system do
  let(:admin) { create(:admin) }
  let(:equipment_kind) { create(:equipment_kind) }
  let(:equipment) { create(:equipment, equipment_kind: equipment_kind, name: "Equipo de informe") }
  let(:location_equipment) { create(:location_equipment, equipment: equipment, code: "EQ-300") }

  before { login_as(admin, scope: :user) }

  it "creates a classic report from the equipment" do
    visit location_equipment_path(location_equipment)
    click_on "Button link"

    expect(page).to have_text("Nuevo Informe")

    fill_in "Observaciones", with: "Revisión de prueba"
    click_on "Aceptar"

    expect(page).to have_text(Time.zone.today.strftime("%d/%m/%Y"))
    expect(location_equipment.reports.last.observations).to eq("Revisión de prueba")
  end

  it "creates a template report from the equipment" do
    template = create(:report_template, name: "Plantilla de sala")

    visit location_equipment_path(location_equipment)
    click_on "Button link"
    click_on "Plantilla"

    expect(page).to have_text("Buscar plantilla")
    expect(page).to have_field(with: template.name)

    click_on "Aceptar"

    expect(page).to have_text(Time.zone.today.strftime("%d/%m/%Y"))
    expect(location_equipment.reports.last.report_template).to eq(template)
  end
end