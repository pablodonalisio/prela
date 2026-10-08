require "rails_helper"

RSpec.describe "Scheduling a service", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "keeps the schedule fields aligned and stacks the time under the date" do
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
    expect(find_field("Inicio programado")[:min]).to eq(Date.current.iso8601)
    expect_schedule_fields_aligned

    init = 1.day.from_now.change(hour: 11, min: 0, sec: 0)
    finish = init.change(hour: 12, min: 15)

    fill_schedule "Inicio programado", init
    fill_schedule "Fin programado", init.change(hour: 9)
    expect(find_field("Fin programado")[:min]).to eq(init.to_date.iso8601)
    expect(find_field("Fin programado").value).to eq("")
    click_button "Programar"

    expect(page).to have_text("Programar servicio")
    expect(page).to have_css("#service_occurrence_planned_on_finish_date:invalid")
    expect_schedule_fields_aligned

    fill_schedule "Fin programado", finish
    click_button "Programar"

    expect(page).to have_text("El servicio se programó correctamente.")
    expect_time_under_date("Inspección programada", "12:15")

    visit agenda_index_path

    expect_time_under_date("Inspección programada", "12:15")
  end

  def fill_schedule(label, time)
    picker = schedule_picker(label)
    date_field = picker.find_field(label)
    time_field = picker.find_field("Hora (formato 24hs)")

    page.execute_script(<<~JS, date_field.native, time.year, time.month, time.day, time_field.native, time.strftime("%H:%M"))
      const input = arguments[0]
      input.datepicker.setDate(new Date(arguments[1], arguments[2] - 1, arguments[3]))
      const timeInput = arguments[4]
      timeInput.value = arguments[5]
      timeInput.dispatchEvent(new Event("input", { bubbles: true }))
      timeInput.dispatchEvent(new Event("change", { bubbles: true }))
    JS
  end

  def expect_schedule_fields_aligned
    ["Inicio programado", "Fin programado"].each do |label|
      picker = schedule_picker(label)
      date_field = picker.find_field(label)
      time_field = picker.find_field("Hora (formato 24hs)")

      expect((time_field.rect.y - date_field.rect.y).abs).to be <= 2
      expect((time_field.rect.height - date_field.rect.height).abs).to be <= 2
    end
  end

  def schedule_picker(label)
    find("label", text: label, exact_text: true).ancestor("[data-controller='datetime-field']")
  end

  def expect_time_under_date(row_text, time_text)
    row = find("tr", text: row_text)
    time = row.find("span", text: time_text)
    cell = time.find(:xpath, "./ancestor::td[1]")
    date = cell.find("span", text: %r{\A\d{2}/\d{2}/\d{4}\z})

    expect(time.rect.y).to be > date.rect.y
    expect(font_size(date) - font_size(time)).to be_within(0.2).of(2)
    expect(text_color(time)).to eq(text_color(date))

    start_cell = row.all("td")[0]
    finish_cell = row.all("td")[1]
    expect(text_color(finish_cell)).to eq(text_color(start_cell))
  end

  def font_size(element)
    page.evaluate_script("parseFloat(getComputedStyle(arguments[0]).fontSize)", element)
  end

  def text_color(element)
    page.evaluate_script("getComputedStyle(arguments[0]).color", element)
  end
end
