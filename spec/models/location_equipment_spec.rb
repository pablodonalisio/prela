require "rails_helper"

RSpec.describe LocationEquipment, type: :model do
  context "associations" do
    let(:location_equipment) { create(:location_equipment) }

    it "belongs to a location" do
      expect(location_equipment.location).to be_a(Location)
    end

    it "belongs to an equipment" do
      expect(location_equipment.equipment).to be_a(Equipment)
    end

    it "has many equipment supplies" do
      create_list(:equipment_supply, 3, equipmentable: location_equipment)
      expect(location_equipment.equipment_supplies.size).to eq(3)
    end

    it "has one equipment battery" do
      create(:equipment_supply, equipmentable: location_equipment)
      expect(location_equipment.equipment_battery).to be_a(EquipmentSupply)
    end

    it "has one battery through equipment battery" do
      battery = create(:battery)
      create(:equipment_supply, equipmentable: location_equipment, suppliable: battery)
      expect(location_equipment.battery).to eq(battery)
    end

    it "has many documents" do
      create_list(:document, 3, documentable: location_equipment)
      expect(location_equipment.documents.size).to eq(3)
    end
  end

  context "filter scopes" do
    let!(:location_equipment1) { create(:location_equipment, status: LocationEquipment.statuses.keys[0]) }
    let!(:location_equipment2) { create(:location_equipment, status: LocationEquipment.statuses.keys[1]) }

    it "returns location equipments by client ids" do
      expect(LocationEquipment.by_client_ids([location_equipment1.location.client_id]).count).to eq(1)
    end

    it "returns location equipments by location ids" do
      expect(LocationEquipment.by_location_ids([location_equipment1.location_id]).count).to eq(1)
    end

    it "returns location equipments by status" do
      expect(LocationEquipment.by_status(LocationEquipment.statuses.keys[0]).count).to eq(1)
    end

    it "returns location equipments by tag ids" do
      tag = create(:tag)
      location_equipment1.tags << tag

      expect(LocationEquipment.by_tag_ids([tag.id])).to contain_exactly(location_equipment1)
    end
  end

  describe "tags" do
    it "can be associated with tags through taggings" do
      location_equipment = create(:location_equipment)
      tag = create(:tag)
      location_equipment.tags << tag

      expect(location_equipment.tags).to include(tag)
      expect(tag.taggings.first.taggable).to eq(location_equipment)
    end
  end

  describe ".visible" do
    it "excludes discarded records and records with discarded ancestors" do
      visible = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      discarded = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      discarded.discard
      with_discarded_location = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      with_discarded_location.location.discard
      with_discarded_client = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      with_discarded_client.location.client.discard
      with_discarded_equipment = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      with_discarded_equipment.equipment.discard
      with_discarded_kind = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      with_discarded_kind.equipment.equipment_kind.discard

      expect(LocationEquipment.visible).to include(visible)
      expect(LocationEquipment.visible).not_to include(
        discarded, with_discarded_location, with_discarded_client, with_discarded_equipment, with_discarded_kind
      )
      expect(with_discarded_client.reload).to be_kept
    end

    it "includes records again after undiscarding an ancestor" do
      location_equipment = create(:location_equipment, equipment: create(:equipment, equipment_kind: create(:equipment_kind)))
      location_equipment.location.client.discard

      expect(LocationEquipment.visible).not_to include(location_equipment)

      location_equipment.location.client.undiscard

      expect(LocationEquipment.visible).to include(location_equipment)
    end
  end


  context "methods" do
    let(:ups) { create(:location_equipment, equipment: create(:equipment, :ups)) }
    let(:power_unit) { create(:location_equipment, equipment: create(:equipment, :power_unit)) }
    let(:electrical_panel) { create(:location_equipment, equipment: create(:equipment, :electrical_panel)) }
    let(:building) { create(:location_equipment, equipment: create(:equipment, :building)) }
    let(:undefined_equipment) { create(:location_equipment) }

    describe "next_service_dates" do
      let!(:location_equipment) do
        location_equipment = create(:location_equipment, equipment: create(:equipment, :power_unit))
        location_equipment.service_dates.destroy_all # Remove default next service dates created by after_create callback
        location_equipment
      end
      let!(:older_battery_change) { create(:service_date, kind: :battery_change, date: 2.years.ago, location_equipment: location_equipment) }
      let!(:older_service) { create(:service_date, kind: :service, date: 1.years.ago, location_equipment: location_equipment) }
      let!(:older_belt_change) { create(:service_date, kind: :belt_change, date: 5.years.ago, location_equipment: location_equipment) }
      let!(:next_battery_change) { create(:service_date, kind: :battery_change, date: Date.current, location_equipment: location_equipment) }
      let!(:next_service) { create(:service_date, kind: :service, date: Date.current, location_equipment: location_equipment) }
      let!(:next_belt_change) { create(:service_date, kind: :belt_change, date: Date.current, location_equipment: location_equipment) }

      it "returns next service dates for location equipment" do
        expect(location_equipment.next_service_dates.map { |sd| sd.date.to_date }).to all(eq(Date.current))
        expect(location_equipment.next_service_dates.size).to eq(LocationEquipment::SERVICE_KINDS[location_equipment.kind].size)
      end
    end

    describe "last_service_date" do
      let(:location_equipment) { create(:location_equipment) }
      let!(:activity) { create(:activity, kind: Activity::BATTERY_CHANGE, date: Date.today, location_equipment: location_equipment) }

      it "returns last service date" do
        expect(location_equipment.last_service_date(:last_battery_change).to_date).to eq(Date.today)
      end

      it "should raise error for undefined activity kind" do
        expect { location_equipment.last_service_date(:undefined_kind) }.to raise_error("Undefined activity kind")
      end
    end

    describe "create_next_service_dates" do
      let(:service_kinds) { %i[service battery_change belt_change] }

      it "creates first next service dates after location equipment creation" do
        freeze_time

        expect(power_unit.next_service_dates.size).to eq(LocationEquipment::SERVICE_KINDS[power_unit.kind].size)
        expect(power_unit.next_service_dates.service.first.date).to eq(1.year.from_now)
        expect(power_unit.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
        expect(power_unit.next_service_dates.belt_change.first.date).to eq(5.years.from_now)
      end

      it "creates new next service dates for power unit from specific time" do
        freeze_time
        power_unit.create_next_service_dates(Time.current, service_kinds)

        expect(power_unit.next_service_dates.size).to eq(LocationEquipment::SERVICE_KINDS[power_unit.kind].size)
        expect(power_unit.next_service_dates.service.first.date).to eq(1.year.from_now)
        expect(power_unit.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
        expect(power_unit.next_service_dates.belt_change.first.date).to eq(5.years.from_now)
      end

      it "creates new next service dates for ups" do
        freeze_time
        ups.create_next_service_dates(Time.current)

        expect(ups.next_service_dates.size).to eq(1)
        expect(ups.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
      end

      it "creates new next service dates for electrical panel" do
        freeze_time
        electrical_panel.create_next_service_dates(Time.current)

        expect(electrical_panel.next_service_dates.size).to eq(3)
        expect(electrical_panel.next_service_dates.service.first.date).to eq(1.year.from_now)
        expect(electrical_panel.next_service_dates.torque.first.date).to eq(1.year.from_now)
        expect(electrical_panel.next_service_dates.cleaning.first.date).to eq(1.year.from_now)
      end

      it "creates new next service dates for building" do
        freeze_time
        building.create_next_service_dates(Time.current)

        expect(building.next_service_dates.size).to eq(3)
        expect(building.next_service_dates.srt_900.first.date).to eq(1.year.from_now)
        expect(building.next_service_dates.thermography.first.date).to eq(1.year.from_now)
        expect(building.next_service_dates.electrical_approval.first.date).to eq(1.year.from_now)
      end
    end

    describe "calculate_next_service_date" do
      it "calculates next service date for specific service kind" do
        freeze_time

        expect(power_unit.calculate_next_service_date(:service)).to eq(1.year.from_now)
        expect(power_unit.calculate_next_service_date(:battery_change)).to eq(2.years.from_now)
        expect(power_unit.calculate_next_service_date(:belt_change)).to eq(5.years.from_now)
      end

      it "calculates next service date for specific service kind from specific time" do
        freeze_time

        expect(power_unit.calculate_next_service_date(:service, 1.year.from_now)).to eq(2.years.from_now)
        expect(power_unit.calculate_next_service_date(:battery_change, 2.years.from_now)).to eq(4.years.from_now)
        expect(power_unit.calculate_next_service_date(:belt_change, 5.years.from_now)).to eq(10.years.from_now)
      end
    end
  end

  context "SERVICE_KINDS constant" do
    it "defines service kinds for each equipment kind" do
      expect(LocationEquipment::SERVICE_KINDS.keys.size).to eq(Equipment::LEGACY_KINDS.size)
    end
  end

  context "#condition_color" do
    let(:location_equipment) { create(:location_equipment, condition: "Buena") }
    it "should return condition color to display" do
      expect(location_equipment.condition_color).to eq("success")
    end
  end

  context "model attributes" do
    it "stores serial_number and code as columns" do
      location_equipment = create(:location_equipment, serial_number: "SN-123", code: "ABC-123")
      expect(location_equipment.serial_number).to eq("SN-123")
      expect(location_equipment.code).to eq("ABC-123")
    end
  end

  context "field_values" do
    it "can store arbitrary key/value pairs" do
      location_equipment = build(:location_equipment, field_values: {"form_link" => "https://example.com", "battery_change_interval" => 2})
      expect(location_equipment.field_values["form_link"]).to eq("https://example.com")
      expect(location_equipment.field_values["battery_change_interval"]).to eq(2)
    end
  end
end
