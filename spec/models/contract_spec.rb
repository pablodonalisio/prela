require "rails_helper"

RSpec.describe Contract, type: :model do
  let(:client) { create(:client) }

  it "is valid with a name, files, and dates" do
    expect(build(:contract, client:)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:contract, client:, name: "")).not_to be_valid
  end

  it "is not valid without a file" do
    expect(build(:contract, client:, files: [])).not_to be_valid
  end

  it "is not valid without a start date" do
    expect(build(:contract, client:, starts_on: nil)).not_to be_valid
  end

  it "is not valid without an end date" do
    expect(build(:contract, client:, ends_on: nil)).not_to be_valid
  end

  it "is not valid when the end date is before the start date" do
    contract = build(:contract, client:, starts_on: Date.current, ends_on: Date.yesterday)

    expect(contract).not_to be_valid
    expect(contract.errors[:ends_on]).to include("debe ser posterior o igual a la fecha de inicio")
  end

  it "is valid when the end date is the same as the start date" do
    expect(build(:contract, client:, starts_on: Date.current, ends_on: Date.current)).to be_valid
  end

  it "attaches the contract files" do
    image = Rack::Test::UploadedFile.new(Rails.root.join("spec/test_files/placeholder-img.jpeg"), "image/jpeg")
    contract = create(:contract, client:, files: [
      Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf"),
      image
    ])

    expect(contract.files).to be_attached
    expect(contract.files.map { |file| file.filename.to_s }).to contain_exactly("test.pdf", "placeholder-img.jpeg")
  end

  it "is not valid with an unsupported file type" do
    contract = build(:contract, client:)
    contract.files.attach(io: StringIO.new("hola"), filename: "notes.txt", content_type: "text/plain")

    expect(contract).not_to be_valid
    expect(contract.errors[:files]).to include("debe ser PDF, Word, JPEG o PNG")
  end
end
