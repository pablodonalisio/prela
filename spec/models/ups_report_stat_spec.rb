require "rails_helper"

RSpec.describe UpsReportStat, type: :model do
  describe "battery_charge" do
    it "is invalid if it is less than 0" do
      ups_report_stat = build(:ups_report_stat, battery_charge: -1)
      expect(ups_report_stat).to be_invalid
    end

    it "is invalid if it is greater than 100" do
      ups_report_stat = build(:ups_report_stat, battery_charge: 101)
      expect(ups_report_stat).to be_invalid
    end
  end
end
