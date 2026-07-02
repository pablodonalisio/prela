require "rails_helper"

RSpec.describe Report, type: :model do
  context "associations" do
    let(:report) { create(:report) }

    it "belongs to a location_equipment" do
      expect(report.location_equipment).to be_a(LocationEquipment)
    end
  end

  describe "#template_based?" do
    it "returns true when report_template is present" do
      report = build(:report, :template_based)
      expect(report.template_based?).to be true
    end

    it "returns false for legacy reports" do
      report = build(:report)
      expect(report.template_based?).to be false
    end
  end

  describe "template report validations" do
    it "requires a report template when template based" do
      report = build(:report, report_template_id: 999_999)
      expect(report).not_to be_valid
    end

    it "rejects invalid field value types" do
      report = build(:report, :template_based, field_values: {"measurements" => {"1739280000" => "not-a-number"}})
      expect(report).not_to be_valid
      expect(report.errors[:field_values]).to be_present
    end
  end

  describe "image limit" do
    it "rejects more than MAX_IMAGES images" do
      report = build(:report)
      report.images.attach(
        Array.new(Report::MAX_IMAGES + 1) do
          {io: File.open(Rails.root.join("app/assets/images/placeholder-img.jpeg")), filename: "test.jpg", content_type: "image/jpeg"}
        end
      )
      expect(report).not_to be_valid
      expect(report.errors[:images]).to be_present
    end
  end
end
