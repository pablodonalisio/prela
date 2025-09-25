import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.checkboxTargets.forEach((checkbox) => {
      const input = document.getElementById(checkbox.dataset.inputId);
      if (Math.round(input.value) === -1) {
        checkbox.checked = true;
        input.hidden = true;
      }
    });
  }

  toggleDisabled(event) {
    const checkbox = event.target;
    const input = document.getElementById(checkbox.dataset.inputId);
    input.hidden = checkbox.checked;
    input.hidden ? (input.value = -1) : (input.value = "");
  }
}
