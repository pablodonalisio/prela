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
        planned_on_init: (Date.current.beginning_of_week + 2.days).in_time_zone.change(hour: 9, min: 0, sec: 0),
        due_on: 1.month.from_now.to_date)
    end

    it "shows scheduled occurrences in the default range" do
      get agenda_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Agenda")
      expect(response.body).to include("Vencimiento Service")
      expect(response.body).to include("Inicio Service")
      expect(response.body).to include("Fin Service")
      expect(response.body).to include(scheduled_in_range.due_on.strftime("%d/%m/%Y"))
      expect(response.body).to include(service_kind.name)
      expect(response.body).to include("Programado")
      expect(response.body).to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
      expect(response.body).to include("09:00")
      expect(response.body).to include("10:00")
    end

    it "shows pending occurrences using due_on and Pendiente badge" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      pending_in_range = create(:service_occurrence,
        location_equipment_service: battery_les,
        due_on: Date.current.beginning_of_week + 1.day)

      get agenda_index_path

      expect(response.body).to include("Pendiente")
      expect(response.body).to include(pending_in_range.due_on.strftime("%d/%m/%Y"))
    end

    it "shows suspended occurrences using due_on" do
      belt_les = location_equipment.location_equipment_services.find_by!(service_kind: belt_change_kind)
      belt_les.service_occurrences.destroy_all
      suspended = create(:service_occurrence, :suspended,
        location_equipment_service: belt_les,
        due_on: scheduled_in_range.planned_on_init.to_date,
        notes: "Espera cliente")

      get agenda_index_path

      expect(response.body).to include("Suspendido")
      expect(response.body).to include("Espera cliente")
      expect(response.body).to include(suspended.due_on.strftime("%d/%m/%Y"))
    end

    it "shows service actions for admins" do
      get agenda_index_path

      expect(response.body).to include("Registrar servicio")
      expect(response.body).to include("Editar prioridad")
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
        planned_on_init: (Date.current + 91).in_time_zone.change(hour: 9, min: 0, sec: 0),
        due_on: Date.current + 91)

      get agenda_index_path

      expect(response.body).to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
      expect(response.body).not_to include("No mostrar")
      expect(response.body).not_to include("UPS Fuera de rango")
      expect(response.body).not_to include(out_of_range.planned_on_init.strftime("%d/%m/%Y"))
    end

    it "defaults Desde to the earliest pending or scheduled date and Hasta to 90 days from today" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      early_pending = create(:service_occurrence,
        location_equipment_service: battery_les,
        due_on: Date.current - 20)

      belt_les = location_equipment.location_equipment_services.find_by!(service_kind: belt_change_kind)
      belt_les.service_occurrences.destroy_all
      create(:service_occurrence, :suspended,
        location_equipment_service: belt_les,
        due_on: Date.current - 40,
        notes: "Antes del inicio")

      get agenda_index_path

      expect(response.body).to include(%(value="#{early_pending.due_on.iso8601}"))
      expect(response.body).to include(%(value="#{(Date.current + 90).iso8601}"))
      expect(response.body).to include(early_pending.due_on.strftime("%d/%m/%Y"))
      expect(response.body).not_to include("Antes del inicio")
    end

    it "uses explicit from and to over the default window" do
      from = Date.current + 10
      to = Date.current + 12

      get agenda_index_path, params: {from: from.iso8601, to: to.iso8601}

      expect(response.body).to include(%(value="#{from.iso8601}"))
      expect(response.body).to include(%(value="#{to.iso8601}"))
      expect(response.body).not_to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
    end

    it "filters by service_kind_id" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      battery_scheduled = create(:service_occurrence, :scheduled,
        location_equipment_service: battery_les,
        planned_on_init: (Date.current.beginning_of_week + 1.day).in_time_zone.change(hour: 9, min: 0, sec: 0),
        due_on: 1.month.from_now.to_date)

      get agenda_index_path, params: {service_kind_id: battery_change_kind.id}

      expect(response.body).to include(battery_scheduled.planned_on_init.strftime("%d/%m/%Y"))
      expect(response.body).not_to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
    end

    it "filters by priority" do
      battery_les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
      battery_les.service_occurrences.destroy_all
      battery_scheduled = create(:service_occurrence, :scheduled,
        location_equipment_service: battery_les,
        planned_on_init: (Date.current.beginning_of_week + 1.day).in_time_zone.change(hour: 9, min: 0, sec: 0),
        due_on: 1.month.from_now.to_date)
      battery_scheduled.update!(priority: :critical)
      scheduled_in_range.update!(priority: :low)

      get agenda_index_path, params: {priority: "critical"}

      expect(response.body).to include(battery_scheduled.planned_on_init.strftime("%d/%m/%Y"))
      expect(response.body).not_to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
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
        planned_on_init: (Date.current.beginning_of_week + 1.day).in_time_zone.change(hour: 9, min: 0, sec: 0),
        due_on: 1.month.from_now.to_date)

      get agenda_index_path, params: {client_id: other_client.id}

      expect(response.body).to include("Cliente filtrado")
      expect(response.body).to include(other_scheduled.planned_on_init.strftime("%d/%m/%Y"))
      expect(response.body).not_to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
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
          planned_on_init: (Date.current.beginning_of_week + 3.days).in_time_zone.change(hour: 9, min: 0, sec: 0),
          due_on: 1.month.from_now.to_date)

        get agenda_index_path

        expect(response.body).to include("Cliente propio")
        expect(response.body).to include(scheduled_in_range.planned_on_init.strftime("%d/%m/%Y"))
        expect(response.body).not_to include("Otro cliente")
        expect(response.body).not_to include(other_scheduled.planned_on_init.strftime("%d/%m/%Y"))
        expect(response.body).not_to include("Registrar servicio")
      end
    end
  end
end
