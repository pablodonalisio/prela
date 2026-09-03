require "rails_helper"

RSpec.describe "Homes", type: :request do
  before do
    sign_in create(:admin)
    ServiceKind.ensure_legacy_kinds!
    %i[ups power_unit electrical_panel building].each do |kind|
      create(:equipment_kind, kind) unless EquipmentKind.exists?(legacy_kind: kind.to_s)
    end
    ServiceKind.ensure_legacy_equipment_assignments!
  end

  describe "GET /index" do
    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:success)
    end

    context "control panel" do
      let!(:location_equipment) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }
      let(:service_kind) { ServiceKind.find_by!(legacy_key: "service") }
      let(:battery_change_kind) { ServiceKind.find_by!(legacy_key: "battery_change") }
      let!(:overdue_occurrence) {
        les = location_equipment.location_equipment_services.find_by!(service_kind: service_kind)
        les.service_occurrences.pending.destroy_all
        create(:service_occurrence, :overdue, location_equipment_service: les, due_on: Date.new(2020, 1, 15))
      }
      let!(:non_overdue_occurrence) {
        les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
        les.service_occurrences.pending.destroy_all
        create(:service_occurrence, due_on: 4.months.from_now.to_date, location_equipment_service: les)
      }

      it "shows services due for attention to admins" do
        get "/home/index"
        expect(response.body).to include("Tipo: #{service_kind.name}")
        expect(response.body).not_to include("Tipo: #{battery_change_kind.name}")
      end

      it "keeps suspended occurrences in the same panel with a Suspendido badge" do
        overdue_occurrence.update!(status: :suspended, notes: "Espera cliente")

        get "/home/index"

        expect(response.body).to include(location_equipment.equipment.equipment_kind.name)
        expect(response.body).to include(">Suspendido<")
        expect(response.body).to include("Notas: Espera cliente")
        expect(response.body).to include("Tipo: #{service_kind.name}")
        expect(response.body).not_to include("Vencidos / por vencer")
        expect(response.body).not_to include(">Vencido<")
      end

      it "includes far-future suspended occurrences in the panel" do
        les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
        les.service_occurrences.destroy_all
        create(:service_occurrence,
          location_equipment_service: les,
          status: :suspended,
          due_on: 4.months.from_now.to_date,
          notes: "Lejos")

        get "/home/index"

        expect(response.body).to include("Notas: Lejos")
        expect(response.body).to include("Tipo: #{battery_change_kind.name}")
      end

      it "shows overdue and suspended counts next to the equipment kind name" do
        les = location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
        les.service_occurrences.destroy_all
        create(:service_occurrence, :due_soon, location_equipment_service: les)
        overdue_occurrence.update!(status: :suspended)

        get "/home/index"

        kind_name = location_equipment.equipment.equipment_kind.name
        expect(response.body).to include(kind_name)
        expect(response.body).to include("text-warning")
        expect(response.body).to include("text-white-50")
        expect(response.body).to include("(1)")
      end

      it "shows building equipment kinds in the control panel" do
        building = create(:location_equipment, equipment: create(:equipment, :building))
        les = building.location_equipment_services.joins(:service_kind).find_by!(service_kinds: {legacy_key: "srt_900"})
        les.service_occurrences.destroy_all
        create(:service_occurrence, :overdue, location_equipment_service: les)

        get "/home/index"

        expect(response.body).to include(building.equipment.equipment_kind.name)
        expect(response.body).to include("Tipo: #{les.service_kind.name}")
      end

      context "when user is not admin" do
        let(:user) { create(:user, client: create(:client)) }
        let!(:client_location_equipment) { create(:location_equipment, location: create(:location, client: user.client), equipment: create(:equipment, :power_unit)) }
        let!(:client_overdue_occurrence) {
          les = client_location_equipment.location_equipment_services.find_by!(service_kind: service_kind)
          les.service_occurrences.pending.destroy_all
          create(:service_occurrence, :overdue, location_equipment_service: les, due_on: Date.new(2021, 2, 20))
        }
        let!(:client_non_overdue_occurrence) {
          les = client_location_equipment.location_equipment_services.find_by!(service_kind: battery_change_kind)
          les.service_occurrences.pending.destroy_all
          create(:service_occurrence, due_on: 4.months.from_now.to_date, location_equipment_service: les)
        }
        let!(:non_client_overdue_occurrence) { overdue_occurrence }

        before do
          sign_in user
        end

        it "only shows services that belongs to the user's client" do
          get "/home/index"
          expect(response.body).to include("Cliente: #{user.client.name}")
          expect(response.body).to include("Fecha: #{client_overdue_occurrence.due_on.strftime("%d/%m/%Y")}")
          expect(response.body).not_to include("Fecha: #{client_non_overdue_occurrence.due_on.strftime("%d/%m/%Y")}")
          expect(response.body).not_to include("Fecha: #{non_client_overdue_occurrence.due_on.strftime("%d/%m/%Y")}")
        end

        it "scopes suspended services to the user's client" do
          client_overdue_occurrence.update!(status: :suspended, notes: "Cliente propio")
          non_client_overdue_occurrence.update!(status: :suspended, notes: "Otro cliente")

          get "/home/index"

          expect(response.body).to include("Notas: Cliente propio")
          expect(response.body).not_to include("Notas: Otro cliente")
        end
      end
    end
  end
end
