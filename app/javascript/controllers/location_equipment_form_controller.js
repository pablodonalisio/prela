import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["client", "equipment"];

  connect() {
    this.displayInputsForEquipmentKind();
  }

  loadLocations() {
    const clientId = this.clientTarget.value;
    const frame = document.getElementById("le_location_inputs");
    if (!frame) return;

    if (clientId) {
      frame.src = `/location_equipments/location_inputs?client_id=${clientId}`;
    } else {
      frame.innerHTML = "";
      frame.removeAttribute("src");
    }
  }

  displayInputsForEquipmentKind() {
    const equipmentId = this.equipmentTarget.value;
    const frame = document.getElementById("le_field_inputs");

    if (!equipmentId || !frame) return;

    frame.src = `/location_equipments/field_inputs?equipment_id=${equipmentId}`;
  }
}
