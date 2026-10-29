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
    it "requires an existing report template on create" do
      report = build(:report, report_template_id: 999_999)
      expect(report).not_to be_valid
    end

    it "rejects an editable cell value that does not match its type" do
      report = build(:report, :template_based)
      section = report.report_template.sections.find_by!(title: "Tensión L1")
      report.section_inputs = {
        section.id.to_s => {"cells" => {"0_1" => {"value" => "not-a-number"}}}
      }

      expect(report).not_to be_valid
    end

    it "copies boolean option labels as records owned by the report" do
      template = create(:report_template, :with_measurements)
      source = template.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1)
      source.update!(value_type: "boolean", for_metrics: false, fixed: false)
      source.table_cell_options.find_by!(value: true).update!(label: "Aprobado")
      source.table_cell_options.find_by!(value: false).update!(label: "Rechazado")

      report = create(:report, :template_based, report_template: template)
      copied = report.sections.find_by!(title: "Tensión L1").table_section.table_cells.find_by!(row_index: 0, column_index: 1)
      option = copied.table_cell_options.find_by!(value: true)

      expect(option.label).to eq("Aprobado")
      expect(option.id).not_to eq(source.table_cell_options.find_by!(value: true).id)
      expect(copied.option_label(false)).to eq("Rechazado")
    end

    it "copies table labels as records owned by the report" do
      report = create(:report, :template_based)
      source = report.report_template.sections.find_by!(title: "Tensión L1").table_section
      copied = report.sections.find_by!(title: "Tensión L1").table_section
      label = copied.table_labels.find_by!(axis: "column", position: 0)

      expect(label.label).to eq("Fase")
      expect(label.id).not_to eq(source.table_labels.find_by!(axis: "column", position: 0).id)
      expect(copied.table_labels.count).to eq(source.table_labels.count)
    end

    it "keeps fixed cell values" do
      report = create(:report, :template_based)
      section = report.sections.find_by!(title: "Tensión L1")
      report.section_inputs = {
        section.id.to_s => {"cells" => {"0_0" => {"value" => "cambiado"}, "0_1" => {"value" => "230"}}}
      }

      expect(report.save).to be true
      cells = section.table_section.table_cells
      expect(cells.find_by!(row_index: 0, column_index: 0).value).to eq("L1")
      expect(cells.find_by!(row_index: 0, column_index: 1).value).to eq("230")
    end

    it "does not change a generated report when the template changes" do
      report = create(:report, :template_based)
      report.report_template.sections.find_by!(title: "Notas").update!(title: "Notas editadas")

      expect(report.reload.sections.find_by(title: "Notas")).to be_present
      expect(report.sections.find_by(title: "Notas editadas")).to be_nil
    end
  end

  describe "uploaded report" do
    it "requires a file" do
      report = build(:report, uploaded: true)

      expect(report).not_to be_valid
      expect(report.errors[:files]).to include("no puede estar en blanco")
    end

    it "rejects a file that is not a PDF or image" do
      report = build(:report, uploaded: true)
      report.files.attach(io: StringIO.new("notes"), filename: "notes.txt", content_type: "text/plain")

      expect(report).not_to be_valid
      expect(report.errors[:files]).to include("debe ser PDF, JPEG o PNG")
    end

    it "accepts a PDF and a JPEG and does not assign a report number" do
      report = build(:report, :uploaded)
      report.files.attach(
        io: StringIO.new(File.binread(Rails.root.join("app/assets/images/placeholder-img.jpeg"))),
        filename: "photo.jpg",
        content_type: "image/jpeg"
      )

      expect(report).to be_valid
      report.save!

      expect(report.files.map(&:content_type)).to contain_exactly("application/pdf", "image/jpeg")
      expect(report.number).to be_nil
      expect(report.report_code).to be_nil
    end

    it "rejects more than the maximum number of files" do
      report = build(:report, uploaded: true)
      Report::MAX_UPLOADED_FILES.succ.times do |index|
        report.files.attach(io: StringIO.new("pdf"), filename: "file-#{index}.pdf", content_type: "application/pdf")
      end

      expect(report).not_to be_valid
      expect(report.errors[:files]).to include("no puede tener más de #{Report::MAX_UPLOADED_FILES} archivos")
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

    it "stores a duplicated signature id once" do
      report.signature_ids = [shared_signature.id, shared_signature.id.to_s, ""]

      expect(report.save).to be true
      expect(report.reload.signatures).to contain_exactly(shared_signature)
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
