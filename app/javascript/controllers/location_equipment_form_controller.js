import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "powerUnitSerialNumbersGroup",
    "serialNumber",
    "equipment",
    "serviceInterval",
    "batteryInterval",
    "beltInterval",
  ];

  connect() {
    this.displaySerialNumberInputs();
    this.displayServiceIntervals();
  }

  displaySerialNumberInputs() {
    let selectedOption = this.equipmentTarget.querySelector("option:checked");
    let kind = selectedOption.dataset.kind;
    if (kind === "power_unit") {
      this.powerUnitSerialNumbersGroupTarget.classList.remove("d-none");
      this.serialNumberTarget.getElementsByTagName("label")[0].innerText =
        "Numero de serie del generador";
    } else {
      this.powerUnitSerialNumbersGroupTarget.classList.add("d-none");
      this.serialNumberTarget.getElementsByTagName("label")[0].innerText =
        "Numero de serie";
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
