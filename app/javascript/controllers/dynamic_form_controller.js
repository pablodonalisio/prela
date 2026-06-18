import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectInput"];

  connect() {
    this.displayInputsForSelectValue();
  }

  displayInputsForSelectValue() {
    this.loadFieldInputs();
  }

  loadFieldInputs() {
    const frame = document.getElementById("eq_field_inputs");
    if (!frame) return;

    const equipmentKindId = this.selectInputTarget.value;
    const equipmentId = frame.dataset.equipmentId || "";
    frame.src = `/equipment/field_inputs?equipment_kind_id=${encodeURIComponent(equipmentKindId)}&equipment_id=${encodeURIComponent(equipmentId)}`;
  }
}
