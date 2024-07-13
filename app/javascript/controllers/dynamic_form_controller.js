import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["inputGroup", "selectInput"];

  connect() {
    this.displayInputsForSelectValue();
  }

  displayInputsForSelectValue() {
    this.inputGroupTargets.forEach((inputGroup) => {
      if (inputGroup.dataset.selectValue === this.selectInputTarget.value) {
        inputGroup.classList.remove("d-none");
        inputGroup.disabled = false;
      } else {
        inputGroup.classList.add("d-none");
        inputGroup.disabled = true;
      }
    });
  }
}
