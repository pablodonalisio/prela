import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element);
  }

  open() {
    if (!this.modal.isOpened) {
      this.modal.show();
    }
  }

  close(event) {
    if (event.detail.success) {
      this.modal.hide();
    }
  }
}
