require "rails_helper"

RSpec.describe PdfGenerator do
  describe "#generate_pdf" do
    let(:data) { "some data" }
    let(:pdf_service_object) { PdfGenerator.call(data) }

    context "when the service object is successful" do
      it "generates a PDF file" do
        expect(pdf_service_object.pdf).to be_a(String)
      end

      it "marks the service object as successful" do
        expect(pdf_service_object).to be_success
      end
    end

    context "when the service object is not successful" do
      it "does not mark the service object as successful" do
        allow_any_instance_of(PdfGenerator).to receive(:generate_pdf).and_raise(StandardError)
        expect(pdf_service_object).not_to be_success
      end
    end
  end
end
