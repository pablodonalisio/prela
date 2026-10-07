require "rails_helper"

RSpec.describe "Report templates", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "opens creation and editing as pages, with fixed sections grouped apart from movable ones" do
    template = create(:report_template, :with_measurements, name: "Preventivo UPS")

    visit report_templates_path
    click_on "Agregar"

    expect(page).to have_current_path(new_report_template_path)
    expect(page).to have_css("h2", text: "Nueva plantilla de informe")
    expect(page).not_to have_css("#remote_modal_title")

    within("[data-fixed-sections]") do
      expect(page).to have_field("Nombre")
      expect(page).to have_text("Especificaciones de equipo")
      expect(page).to have_text("Especificaciones de ubicación")
      expect(page).not_to have_css("[data-sortable-sections-target='item']")
    end

    expect(page).to have_css("[data-sortable-sections-target='list']", text: "Mediciones")

    click_on "Aceptar"
    expect(page).to have_css("h2", text: "Nueva plantilla de informe")
    expect(page).to have_css("[data-fixed-sections] .text-fg-danger")

    visit report_templates_path
    click_on "Acciones"
    click_on "Editar"

    expect(page).to have_current_path(edit_report_template_path(template))
    expect(page).to have_css("h2", text: "Editar plantilla de informe")
    expect(page).to have_field("Nombre", with: "Preventivo UPS")
    expect(page).not_to have_css("#remote_modal_title")
  end
end
