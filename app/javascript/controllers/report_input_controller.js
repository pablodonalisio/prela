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
          input.hidden = true;
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
        input.hidden = true;
        input.value = -1;
      } else {
        input.hidden = false;
        input.value = "";
      }
    });
  }
}
