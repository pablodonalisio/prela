import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "upsInputs",
    "powerUnitInputs",
    "electricalPanelInputs",
    "equipment",
  ];

  connect() {
    this.displayInputsForEquipmentKind();
  }

  displayInputsForEquipmentKind() {
    let selectedOption = this.equipmentTarget.querySelector("option:checked");
    let kind = selectedOption.dataset.kind;
    if (kind === undefined) return;

    let inputsTargets = [
      this.upsInputsTarget,
      this.powerUnitInputsTarget,
      this.electricalPanelInputsTarget,
    ];

    let inputsToDisplay = this.targets.find(`${this.ToCamelCase(kind)}Inputs`);

    inputsTargets = inputsTargets.forEach((input) => {
      if (input !== inputsToDisplay) {
        input.classList.add("d-none");
        input.disabled = true;
      } else {
        input.classList.remove("d-none");
        input.disabled = false;
      }
    });
  }

  ToCamelCase(str) {
    return str.replace(/_([a-z])/g, (g) => g[1].toUpperCase());
  }
}
