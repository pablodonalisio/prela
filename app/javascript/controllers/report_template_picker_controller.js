import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["frame", "select"];
  static values = {
    baseUrl: String,
    reportId: String
  };

  reloadFields() {
    const templateId = this.selectTarget.value;
    if (!templateId || !this.hasFrameTarget) return;

    const url = new URL(this.baseUrlValue, window.location.origin);
    url.searchParams.set("report_template_id", templateId);
    if (this.hasReportIdValue && this.reportIdValue) {
      url.searchParams.set("report_id", this.reportIdValue);
    }

    this.frameTarget.src = url.toString();
  }

  selectAssociated(event) {
    const templateId = event.params.templateId;
    this.selectTarget.value = templateId;
    this.reloadFields();
  }
}
