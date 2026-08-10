import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tooltip"
export default class extends Controller {
  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element);
  }

  disconnect() {
    this.tooltip?.dispose();
  }
}
