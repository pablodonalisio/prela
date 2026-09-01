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

  def clear_location_equipment_services!
    location_equipment.location_equipment_services.find_each do |les|
      les.service_occurrences.destroy_all
      les.destroy!
    end
  end

  before do
    sign_in user
    equipment_kind.service_kinds << service_kind unless equipment_kind.service_kinds.exists?(service_kind.id)
  end

  describe "POST /create" do
    it "creates a location equipment service" do
      clear_location_equipment_services!
      due_on = Date.current

      expect {
        post location_equipment_location_equipment_services_url(location_equipment),
          params: {
            location_equipment_service: {
              service_kind_id: service_kind.id,
              interval: 3,
              interval_unit: "months",
              due_on: due_on
            }
          }
      }.to change(LocationEquipmentService, :count).by(1)
        .and change(ServiceOccurrence.pending, :count).by(1)

      les = location_equipment.reload.location_equipment_services.find_by!(service_kind: service_kind)
      expect(les.interval).to eq(3)
      expect(les.interval_unit).to eq("months")
      expect(les.pending_service_occurrence).to be_present
      expect(les.pending_service_occurrence.due_on).to eq(due_on)
    end

    it "creates a recurring location equipment service with an explicit due_on" do
      clear_location_equipment_services!
      due_on = 2.months.from_now.to_date

      post location_equipment_location_equipment_services_url(location_equipment),
        params: {
          location_equipment_service: {
            service_kind_id: service_kind.id,
            interval: 3,
            interval_unit: "months",
            due_on: due_on
          }
        }

      les = location_equipment.reload.location_equipment_services.find_by!(service_kind: service_kind)
      expect(les.pending_service_occurrence.due_on).to eq(due_on)
    end

    it "creates a one-time location equipment service without interval" do
      clear_location_equipment_services!
      one_time_kind = create(:service_kind, :one_time, name: "Inspección inicial")
      due_on = 1.month.from_now.to_date

      expect {
        post location_equipment_location_equipment_services_url(location_equipment),
          params: {
            location_equipment_service: {
              service_kind_id: one_time_kind.id,
              due_on: due_on
            }
          }
      }.to change(LocationEquipmentService, :count).by(1)
        .and change(ServiceOccurrence.pending, :count).by(1)

      les = location_equipment.reload.location_equipment_services.find_by!(service_kind: one_time_kind)
      expect(les.interval).to be_nil
      expect(les.interval_unit).to be_nil
      expect(les.pending_service_occurrence.due_on).to eq(due_on)
    end

    it "requires due_on for recurring services" do
      clear_location_equipment_services!

      expect {
        post location_equipment_location_equipment_services_url(location_equipment),
          params: {
            location_equipment_service: {
              service_kind_id: service_kind.id,
              interval: 3,
              interval_unit: "months"
            }
          }
      }.not_to change(LocationEquipmentService, :count)
    end

    it "requires due_on for one-time services" do
      clear_location_equipment_services!
      one_time_kind = create(:service_kind, :one_time, name: "Inspección inicial")

      expect {
        post location_equipment_location_equipment_services_url(location_equipment),
          params: {
            location_equipment_service: {
              service_kind_id: one_time_kind.id
            }
          }
      }.not_to change(LocationEquipmentService, :count)
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
      les.service_occurrences.destroy_all

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
