import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "powerUnitSerialNumbersGroup",
    "equipment",
    "serviceInterval",
    "batteryInterval",
    "beltInterval",
  ];

  connect() {
    this.displayPowerUnitSerialNumberInputs();
    this.displayServiceIntervals();
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

  displayServiceIntervals() {
    let selectedOption = this.equipmentTarget.querySelector("option:checked");
    let kind = selectedOption.dataset.kind;
    if (kind === "ups") {
      this.serviceIntervalTarget.classList.add("d-none");
      this.beltIntervalTarget.classList.add("d-none");
    } else {
      this.serviceIntervalTarget.classList.remove("d-none");
      this.beltIntervalTarget.classList.remove("d-none");
    }
  }
}
