require "rails_helper"

RSpec.describe "Signatures", type: :request do
  def create_signature(name:, user: nil)
    signature = Signature.new(name: name, title: "Cargo", user: user)
    signature.image.attach(io: StringIO.new("img"), filename: "sig.png", content_type: "image/png")
    signature.save!
    signature
  end

  context "when user is a technician" do
    let(:technician) { create(:technician) }
    let!(:owned) { create_signature(name: "Firma propia", user: technician) }
    let!(:catalog) { create_signature(name: "Firma del catalogo") }

    before { sign_in technician }

    it "lists only their signature and lets them add one" do
      get signatures_path

      expect(response).to be_successful
      expect(response.body).to include("Firma propia")
      expect(response.body).to include("Agregar")
      expect(response.body).not_to include("Firma del catalogo")
    end

    it "does not edit a signature they do not own" do
      get edit_signature_path(catalog)

      expect(response).to redirect_to(root_path)
    end
  end
end
