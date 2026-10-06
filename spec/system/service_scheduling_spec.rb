require "rails_helper"

RSpec.describe "Scheduling a service", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "keeps the schedule fields aligned, accepts a typed time, and stacks it under the date" do
    equipment = create(:equipment, equipment_kind: create(:equipment_kind), name: "Equipo programable")
    location_equipment = create(:location_equipment, equipment: equipment, code: "EQ-TIME")
    service_kind = create(:service_kind, name: "Inspección programada")
    les = create(:location_equipment_service, location_equipment: location_equipment, service_kind: service_kind)
    les.service_occurrences.destroy_all
    create(:service_occurrence, location_equipment_service: les, due_on: 1.month.from_now.to_date)

    visit location_equipment_path(location_equipment)
    click_on "Servicios"
    click_on "Programar"

    expect(page).to have_text("Programar servicio")
    expect_schedule_fields_aligned

    start_input = find_field("Horario de inicio")
    start_input.click
    expect(page).to have_button("00:00")
    expect(page).to have_button("00:30")
    expect(page).to have_button("23:30")
    expect(page).to have_no_button("00:15")
    click_on "11:00"

    end_input = find_field("Horario de finalización")
    end_input.send_keys("0900")
    expect(end_input.value).to eq("09:00")
    click_button "Programar"

    expect(page).to have_text("debe ser posterior al horario de inicio")
    expect_schedule_fields_aligned

    end_input = find_field("Horario de finalización")
    end_input.set("")
    end_input.send_keys("1")
    expect(end_input.value).to eq("1")
    end_input.send_keys("2")
    expect(end_input.value).to eq("12:")
    end_input.send_keys("15")
    expect(end_input.value).to eq("12:15")
    click_button "Programar"

    expect(page).to have_text("El servicio se programó correctamente.")
    expect_time_under_date("Inspección programada", "12:15")

    visit agenda_index_path

    expect_time_under_date("Inspección programada", "12:15")
  end

  def expect_schedule_fields_aligned
    date_field = find_field("Fecha programada")
    start_input = find_field("Horario de inicio")
    end_input = find_field("Horario de finalización")

    expect((start_input.rect.y - date_field.rect.y).abs).to be <= 2
    expect((end_input.rect.y - date_field.rect.y).abs).to be <= 2
    expect((start_input.rect.height - date_field.rect.height).abs).to be <= 2
    expect((end_input.rect.height - date_field.rect.height).abs).to be <= 2
  end

  def expect_time_under_date(row_text, time_text)
    row = find("tr", text: row_text)
    date = row.find("span", text: %r{\A\d{2}/\d{2}/\d{4}\z})
    time = row.find("span", text: time_text)

    expect(time.rect.y).to be > date.rect.y
    expect(font_size(date) - font_size(time)).to be_within(0.2).of(2)
    expect(text_color(time)).to eq(text_color(date))
  end

  def font_size(element)
    page.evaluate_script("parseFloat(getComputedStyle(arguments[0]).fontSize)", element)
  end

  def text_color(element)
    page.evaluate_script("getComputedStyle(arguments[0]).color", element)
  end
end
