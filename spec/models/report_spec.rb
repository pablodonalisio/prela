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

  describe "report number and report_code" do
    let(:location_equipment) { create(:location_equipment) }

    it "assigns increasing numbers per equipment within the same year" do
      first = create(:report, :template_based, location_equipment: location_equipment, date: Time.zone.local(2026, 3, 1))
      second = create(:report, :template_based, location_equipment: location_equipment, date: Time.zone.local(2026, 8, 15))

      expect(first.number).to eq(1)
      expect(second.number).to eq(2)
    end

    it "resets the number for a new year on the same equipment" do
      create(:report, :template_based, location_equipment: location_equipment, date: Time.zone.local(2025, 6, 1))
      create(:report, :template_based, location_equipment: location_equipment, date: Time.zone.local(2025, 11, 1))
      next_year = create(:report, :template_based, location_equipment: location_equipment, date: Time.zone.local(2026, 1, 10))

      expect(next_year.number).to eq(1)
    end

    it "does not assign a number to legacy reports" do
      report = create(:report, location_equipment: location_equipment)

      expect(report.number).to be_nil
      expect(report.report_code).to be_nil
    end

    it "builds report_code with C/A prefixes and zero-padded segments" do
      report = create(
        :report,
        :template_based,
        location_equipment: location_equipment,
        date: Time.zone.local(2026, 7, 21)
      )
      client = location_equipment.client

      expect(report.report_code).to eq(
        format("C%03d-A%04d-26-%03d", client.id, location_equipment.id, report.number)
      )
    end
  end

  describe "signature selection" do
    def create_signature(name:, user: nil)
      signature = Signature.new(name: name, title: "Cargo", user: user)
      signature.image.attach(io: StringIO.new("img"), filename: "sig.png", content_type: "image/png")
      signature.save!
      signature
    end

    let(:technician) { create(:technician) }
    let(:shared_signature) { create_signature(name: "Compartida") }
    let(:own_signature) { create_signature(name: "Propia", user: technician) }
    let(:other_signature) { create_signature(name: "Ajena", user: create(:technician)) }
    let(:report) { build(:report, :template_based) }

    before do
      report.allowed_signatures = SignaturePolicy::ReportScope.new(technician, Signature).resolve
    end

    it "accepts the technician's signature and unowned signatures" do
      report.signature_ids = [shared_signature.id, own_signature.id]

      expect(report).to be_valid
    end

    it "rejects a signature that belongs to someone else" do
      report.signature_ids = [other_signature.id]

      expect(report).not_to be_valid
      expect(report.errors[:signatures]).to include("incluye una firma que no se puede usar")
    end

    it "keeps a signature already linked to the report" do
      report.save!
      report.signatures << other_signature
      report.allowed_signatures = SignaturePolicy::ReportScope.new(create(:admin), Signature).resolve
      report.signature_ids = [other_signature.id]

      expect(report).to be_valid
    end
  end
end
