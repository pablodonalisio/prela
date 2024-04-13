require "rails_helper"

RSpec.describe Reports::PdfGenerator do
  describe "#generate_pdf" do
    let(:report) { create(:report, ups_report_stat: ups_report_stat) }
    let(:ups_report_stat) { create(:ups_report_stat) }
    let(:pdf_service_object) { described_class.call(report) }

    context "when the service object is successful" do
      it "generates a PDF file" do
        expect(pdf_service_object.pdf).to be_a(String)
      end

      it "marks the service object as successful" do
        expect(pdf_service_object).to be_success
      end

      it "has no error" do
        expect(pdf_service_object.error).to be_nil
      end
    end

    context "when the service object is not successful" do
      it "does not mark the service object as successful" do
        allow_any_instance_of(Reports::PdfGenerator).to receive(:generate_pdf).and_raise(StandardError)
        expect(pdf_service_object).not_to be_success
      end
    end
  end
end
