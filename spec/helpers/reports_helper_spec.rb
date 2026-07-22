require "rails_helper"

RSpec.describe ReportsHelper, type: :helper do
  describe "#maintenance_overdue_status" do
    it "returns :not_ok for a past date" do
      expect(helper.send(:maintenance_overdue_status, Date.yesterday)).to eq(:not_ok)
    end

    it "returns :warning for a date within 3 months" do
      expect(helper.send(:maintenance_overdue_status, 1.month.from_now.to_date)).to eq(:warning)
    end

    it "returns :ok for a date beyond 3 months" do
      expect(helper.send(:maintenance_overdue_status, 4.months.from_now.to_date)).to eq(:ok)
    end

    it "returns nil when the date is blank" do
      expect(helper.send(:maintenance_overdue_status, nil)).to be_nil
    end
  end
end
