import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["kind", "text", "images", "table", "list"];

  connect() {
    this.toggle();
  }

  toggle() {
    const key = this.kindTarget.selectedOptions[0]?.dataset.key || "text";
    this.show(this.textTarget, key === "text");
    this.show(this.imagesTarget, key === "images");
    this.show(this.tableTarget, key === "table");
    this.show(this.listTarget, key === "list");
  }

  show(element, visible) {
    element.classList.toggle("hidden", !visible);
    element.disabled = !visible;
  }
}
