require "rails_helper"

RSpec.describe "Agenda", type: :request do
  before do
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
  end

  let(:user) { create(:admin) }
  let(:location_equipment) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }
  let(:service_kind) { ServiceKind.find_by!(legacy_key: "service") }
  let(:battery_change_kind) { ServiceKind.find_by!(legacy_key: "battery_change") }
  let(:belt_change_kind) { ServiceKind.find_by!(legacy_key: "belt_change") }
  let(:les) { location_equipment.location_equipment_services.find_by!(service_kind: service_kind) }

  before do
    sign_in user
    les.service_occurrences.destroy_all
  end

  describe "GET /agenda" do
    let!(:scheduled_in_range) do
      create(:service_occurrence, :scheduled,
        location_equipment_service: les,
        planned_on: Date.current.beginning_of_week + 2.days,
        due_on: 1.month.from_now.to_date)
    end

    it "shows scheduled occurrences in the default range" do
      get agenda_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Agenda")
      expect(response.body).to include("Fecha")
      expect(response.body).to include(service_kind.name)
      expect(response.body).to include("Programado")
      expect(response.body).to include(scheduled_in_range.planned_on.strftime("%d/%m/%Y"))
    end

    it "shows pending occurrences using due_on and Falta Programar badge" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      pending_in_range = create(:service_occurrence,
        location_equipment_service: battery_les,
        due_on: Date.current.beginning_of_week + 1.day)

      get agenda_index_path

      expect(response.body).to include("Falta Programar")
      expect(response.body).to include(pending_in_range.due_on.strftime("%d/%m/%Y"))
    end

    it "shows suspended occurrences using due_on" do
      belt_les = location_equipment.location_equipment_services.find_by!(service_kind: belt_change_kind)
      belt_les.service_occurrences.destroy_all
      suspended = create(:service_occurrence, :suspended,
        location_equipment_service: belt_les,
        due_on: Date.current.beginning_of_week + 1.day,
        notes: "Espera cliente")

      get agenda_index_path

      expect(response.body).to include("Suspendido")
      expect(response.body).to include("Espera cliente")
      expect(response.body).to include(suspended.due_on.strftime("%d/%m/%Y"))
    end

    it "shows service actions for admins" do
      get agenda_index_path

      expect(response.body).to include("Registrar servicio")
      expect(response.body).to include("Volver a pendiente")
      expect(response.body).to include(complete_location_equipment_service_occurrence_path(location_equipment, scheduled_in_range))
    end

    it "does not show completed or out-of-range occurrences" do
      belt_les = location_equipment.location_equipment_services.find_by!(service_kind: belt_change_kind)
      belt_les.service_occurrences.destroy_all
      create(:service_occurrence, :completed,
        location_equipment_service: belt_les,
        due_on: Date.current,
        completed_on: Date.current,
        notes: "No mostrar")

      ups = create(:location_equipment, equipment: create(:equipment, :ups, model: "UPS Fuera de rango"))
      ups_les = ups.location_equipment_services.find_by!(service_kind: battery_change_kind)
      ups_les.service_occurrences.destroy_all
      out_of_range = create(:service_occurrence, :scheduled,
        location_equipment_service: ups_les,
        planned_on: 3.months.from_now.to_date,
        due_on: 3.months.from_now.to_date)

      get agenda_index_path

      expect(response.body).to include(scheduled_in_range.planned_on.strftime("%d/%m/%Y"))
      expect(response.body).not_to include("No mostrar")
      expect(response.body).not_to include("UPS Fuera de rango")
      expect(response.body).not_to include(out_of_range.planned_on.strftime("%d/%m/%Y"))
    end

    it "filters by service_kind_id" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      battery_scheduled = create(:service_occurrence, :scheduled,
        location_equipment_service: battery_les,
        planned_on: Date.current.beginning_of_week + 1.day,
        due_on: 1.month.from_now.to_date)

      get agenda_index_path, params: {service_kind_id: battery_change_kind.id}

      expect(response.body).to include(battery_scheduled.planned_on.strftime("%d/%m/%Y"))
      expect(response.body).not_to include(scheduled_in_range.planned_on.strftime("%d/%m/%Y"))
    end

    it "filters by client_id" do
      other_client = create(:client, name: "Cliente filtrado")
      other_le = create(:location_equipment,
        location: create(:location, client: other_client),
        equipment: create(:equipment, :power_unit))
      other_les = other_le.location_equipment_services.find_by!(service_kind: service_kind)
      other_les.service_occurrences.destroy_all
      other_scheduled = create(:service_occurrence, :scheduled,
        location_equipment_service: other_les,
        planned_on: Date.current.beginning_of_week + 1.day,
        due_on: 1.month.from_now.to_date)

      get agenda_index_path, params: {client_id: other_client.id}

      expect(response.body).to include("Cliente filtrado")
      expect(response.body).to include(other_scheduled.planned_on.strftime("%d/%m/%Y"))
      expect(response.body).not_to include(scheduled_in_range.planned_on.strftime("%d/%m/%Y"))
    end

    context "when user is a client" do
      let(:user) { create(:user, client: create(:client, name: "Cliente propio")) }
      let(:location_equipment) {
        create(:location_equipment,
          location: create(:location, client: user.client),
          equipment: create(:equipment, :power_unit))
      }

      it "only shows services for the user's client" do
        other_le = create(:location_equipment,
          location: create(:location, client: create(:client, name: "Otro cliente")),
          equipment: create(:equipment, :power_unit))
        other_les = other_le.location_equipment_services.find_by!(service_kind: service_kind)
        other_les.service_occurrences.destroy_all
        other_scheduled = create(:service_occurrence, :scheduled,
          location_equipment_service: other_les,
          planned_on: Date.current.beginning_of_week + 3.days,
          due_on: 1.month.from_now.to_date)

        get agenda_index_path

        expect(response.body).to include("Cliente propio")
        expect(response.body).to include(scheduled_in_range.planned_on.strftime("%d/%m/%Y"))
        expect(response.body).not_to include("Otro cliente")
        expect(response.body).not_to include(other_scheduled.planned_on.strftime("%d/%m/%Y"))
        expect(response.body).not_to include("Registrar servicio")
      end
    end
  end
end
