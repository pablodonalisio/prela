import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["powerUnitSerialNumbersGroup", "equipment"];

  connect() {
    this.displayPowerUnitSerialNumberInputs();
  }

  displayPowerUnitSerialNumberInputs() {
    let selectedOption = this.equipmentTarget.querySelector("option:checked");
    let kind = selectedOption.dataset.kind;
    if (kind === "power_unit") {
      this.powerUnitSerialNumbersGroupTarget.classList.remove("d-none");
    } else {
      this.powerUnitSerialNumbersGroupTarget.classList.add("d-none");
    }
  }
}
