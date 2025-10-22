require "rails_helper"

RSpec.describe Activity, type: :model do
  context "methods" do
    let(:service_activity) { create(:activity, kind: Activity::SERVICE, date: Time.current) }
    let(:battery_change_activity) { create(:activity, kind: Activity::BATTERY_CHANGE, date: Time.current) }
    let(:belt_change_activity) { create(:activity, kind: Activity::BELT_CHANGE, date: Time.current) }
    let(:torque_activity) { create(:activity, kind: Activity::TORQUE, date: Time.current) }
    let(:cleaning_activity) { create(:activity, kind: Activity::CLEANING, date: Time.current) }
    let(:other_activity) { create(:activity, kind: Activity::OTHER) }

    describe "#create_service_date" do
      it "creates service date after activity creation" do
        freeze_time

        expect(service_activity.service_date.service?).to be_truthy
        expect(service_activity.service_date.date).to eq(service_activity.location_equipment.service_interval.years.from_now)

        expect(battery_change_activity.service_date.battery_change?).to be_truthy
        expect(battery_change_activity.service_date.date).to eq(battery_change_activity.location_equipment.battery_change_interval.years.from_now)

        expect(belt_change_activity.service_date.belt_change?).to be_truthy
        expect(belt_change_activity.service_date.date).to eq(belt_change_activity.location_equipment.belt_change_interval.years.from_now)

        expect(torque_activity.service_date.torque?).to be_truthy
        expect(torque_activity.service_date.date).to eq(torque_activity.location_equipment.torque_interval.years.from_now)

        expect(cleaning_activity.service_date.cleaning?).to be_truthy
        expect(cleaning_activity.service_date.date).to eq(cleaning_activity.location_equipment.cleaning_interval.years.from_now)
      end

      it "doesn't create service date for other activity" do
        expect(other_activity.service_date).to be_nil
      end
    end

    describe "#update_service_date" do
      it "updates service date after activity date update" do
        freeze_time

        service_activity.update!(date: 1.year.from_now)
        battery_change_activity.update!(date: 2.years.from_now)
        belt_change_activity.update!(date: 5.years.from_now)
        torque_activity.update!(date: 3.years.from_now)
        cleaning_activity.update!(date: 4.years.from_now)

        expect(service_activity.service_date.date).to eq(service_activity.location_equipment.service_interval.years.from_now + 1.year)
        expect(battery_change_activity.service_date.date).to eq(battery_change_activity.location_equipment.battery_change_interval.years.from_now + 2.years)
        expect(belt_change_activity.service_date.date).to eq(belt_change_activity.location_equipment.belt_change_interval.years.from_now + 5.years)
        expect(torque_activity.service_date.date).to eq(torque_activity.location_equipment.torque_interval.years.from_now + 3.years)
        expect(cleaning_activity.service_date.date).to eq(cleaning_activity.location_equipment.cleaning_interval.years.from_now + 4.years)
      end

      it "updates service kind after activity kind update" do
        freeze_time

        service_activity.update!(kind: Activity::BATTERY_CHANGE)

        expect(service_activity.service_date.battery_change?).to be_truthy
        expect(service_activity.service_date.date).to eq(service_activity.location_equipment.battery_change_interval.years.from_now)
      end

      it "updates both service kind and date after activity kind and date update" do
        freeze_time

        service_activity.update!(kind: Activity::BATTERY_CHANGE, date: 2.years.from_now)

        expect(service_activity.service_date.battery_change?).to be_truthy
        expect(service_activity.service_date.date).to eq(service_activity.location_equipment.battery_change_interval.years.from_now + 2.years)
      end

      it "doesn't update service date after activity description update" do
        freeze_time

        service_activity.update!(description: "New description")
        battery_change_activity.update!(description: "New description")
        belt_change_activity.update!(description: "New description")
        torque_activity.update!(description: "New description")
        cleaning_activity.update!(description: "New description")

        expect(service_activity.service_date.date).to eq(service_activity.location_equipment.service_interval.years.from_now)
        expect(battery_change_activity.service_date.date).to eq(battery_change_activity.location_equipment.battery_change_interval.years.from_now)
        expect(belt_change_activity.service_date.date).to eq(belt_change_activity.location_equipment.belt_change_interval.years.from_now)
        expect(torque_activity.service_date.date).to eq(torque_activity.location_equipment.torque_interval.years.from_now)
        expect(cleaning_activity.service_date.date).to eq(cleaning_activity.location_equipment.cleaning_interval.years.from_now)
      end
    end
  end
end
