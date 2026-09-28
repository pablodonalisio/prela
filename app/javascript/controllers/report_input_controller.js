import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.checkboxTargets.forEach((checkbox) => {
      const inputs = this.#inputs(checkbox);
      // Saving with "Sin datos" unchecked submits a blank value. On the
      // re-render that blank is not "Sin datos": keep the field visible,
      // leave the checkbox unchecked, and let the validation message show.
      if (this.#blankAfterValidation(inputs)) return;

      inputs.forEach((input) => {
        if (!this.#isNoData(input)) return;

        checkbox.checked = true;
        this.#applyNoData(input);
      });
    });
  }

  toggleDisabled(event) {
    const checkbox = event.target;
    this.#inputs(checkbox).forEach((input) => {
      if (checkbox.checked) {
        this.#applyNoData(input);
      } else {
        this.#clearInput(input);
      }
    });
  }

  #inputs(checkbox) {
    const formGroup = document.getElementById(checkbox.dataset.formGroupId);
    if (!formGroup) return [];

    return Array.from(formGroup.querySelectorAll("input, select"));
  }

  #isNoData(input) {
    return input.value === "" || this.#isSentinel(input);
  }

  #blankAfterValidation(inputs) {
    if (inputs.some((input) => this.#isSentinel(input))) return false;

    return inputs.some((input) => input.value === "" && this.#hasValidationError(input));
  }

  #isSentinel(input) {
    return input.value !== "" && Math.round(input.value) === -1;
  }

  #hasValidationError(input) {
    if (input.classList.contains("!border-red-500")) return true;

    const wrapper = input.closest(".mb-5");
    return Boolean(wrapper?.querySelector(".text-fg-danger"));
  }

  // Empty fields are shown as "Sin datos" on load. The checkbox alone is not
  // submitted, so the input must carry the sentinel the server accepts.
  #applyNoData(input) {
    this.#setHidden(input, true);
    if (input.tagName === "SELECT") {
      input.value = "";
      input.dispatchEvent(new Event("change", {bubbles: true}));
      return;
    }

    input.value = -1;
  }

  #clearInput(input) {
    this.#setHidden(input, false);
    input.value = "";
    if (input.tagName === "SELECT") {
      input.dispatchEvent(new Event("change", {bubbles: true}));
    }
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
