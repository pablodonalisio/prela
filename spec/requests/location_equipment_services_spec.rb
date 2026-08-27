require "rails_helper"

RSpec.describe "/location_equipments/:location_equipment_id/location_equipment_services", type: :request do
  let(:user) { create(:admin) }
  let(:equipment_kind) { create(:equipment_kind, :ups) }
  let(:service_kind) {
    ServiceKind.ensure_legacy_kinds!
    ServiceKind.find_by!(legacy_key: "battery_change")
  }
  let(:equipment) { create(:equipment, equipment_kind: equipment_kind) }
  let(:location_equipment) { create(:location_equipment, equipment: equipment) }

  before do
    sign_in user
    equipment_kind.service_kinds << service_kind unless equipment_kind.service_kinds.exists?(service_kind.id)
  end

  describe "POST /create" do
    it "creates a location equipment service" do
      location_equipment.location_equipment_services.destroy_all

      expect {
        post location_equipment_location_equipment_services_url(location_equipment),
          params: {
            location_equipment_service: {
              service_kind_id: service_kind.id,
              interval: 3,
              interval_unit: "months"
            }
          }
      }.to change(LocationEquipmentService, :count).by(1)

      les = location_equipment.reload.location_equipment_services.find_by!(service_kind: service_kind)
      expect(les.interval).to eq(3)
      expect(les.interval_unit).to eq("months")
    end
  end

  describe "PATCH /update" do
    it "updates the interval" do
      les = location_equipment.location_equipment_services.find_by!(service_kind: service_kind)

      patch location_equipment_location_equipment_service_url(location_equipment, les),
        params: {
          location_equipment_service: {interval: 4, interval_unit: "years"}
        }

      expect(les.reload.interval).to eq(4)
      expect(les.interval_unit).to eq("years")
    end
  end

  describe "DELETE /destroy" do
    it "removes the location equipment service" do
      les = location_equipment.location_equipment_services.find_by!(service_kind: service_kind)

      expect {
        delete location_equipment_location_equipment_service_url(location_equipment, les)
      }.to change(LocationEquipmentService, :count).by(-1)
    end
  end

  context "when user is a client" do
    let(:user) { create(:user) }

    it "does not allow updates" do
      les = location_equipment.location_equipment_services.find_by(service_kind: service_kind)
      les ||= create(:location_equipment_service, location_equipment: location_equipment, service_kind: service_kind)

      patch location_equipment_location_equipment_service_url(location_equipment, les),
        params: {location_equipment_service: {interval: 9}}

      expect(response).to redirect_to(root_path)
      expect(les.reload.interval).not_to eq(9)
    end
  end

  context "when user is an editor" do
    let(:user) { create(:user, editor: true) }

    it "does not allow updates" do
      les = location_equipment.location_equipment_services.find_by(service_kind: service_kind)
      les ||= create(:location_equipment_service, location_equipment: location_equipment, service_kind: service_kind)

      patch location_equipment_location_equipment_service_url(location_equipment, les),
        params: {location_equipment_service: {interval: 9}}

      expect(response).to redirect_to(root_path)
      expect(les.reload.interval).not_to eq(9)
    end
  end
end
