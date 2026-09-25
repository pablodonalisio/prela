import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.checkboxTargets.forEach((checkbox) => {
      const formGroup = document.getElementById(checkbox.dataset.formGroupId);
      const inputs = Array.from(formGroup.querySelectorAll("input, select"));
      inputs.forEach((input) => {
        if (input.value === "" || Math.round(input.value) === -1) {
          checkbox.checked = true;
          this.#setHidden(input, true);
        }
      });
    });
  }

  toggleDisabled(event) {
    const checkbox = event.target;
    const formGroup = document.getElementById(checkbox.dataset.formGroupId);
    const inputs = Array.from(formGroup.querySelectorAll("input, select"));
    inputs.forEach((input) => {
      if (checkbox.checked) {
        this.#setHidden(input, true);
        input.value = input.tagName === "SELECT" ? "" : -1;
      } else {
        this.#setHidden(input, false);
        input.value = "";
      }
      if (input.tagName === "SELECT") {
        input.dispatchEvent(new Event("change", {bubbles: true}));
      }
    });
  }

  // Native <select>s are replaced by a custom dropdown inserted next to them.
  // Hiding the field wrapper covers the label and that dropdown; the <select>
  // itself stays visually hidden by the upgrade.
  #setHidden(input, hidden) {
    if (input.tagName === "SELECT") {
      input.parentElement.hidden = hidden;
      return;
    }
    input.hidden = hidden;
  }
}
