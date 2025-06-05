import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];
  static values = {
    locationEquipmentId: Number,
  };

  connect() {
    this.localStorageKey = `location_equipment_${this.locationEquipmentIdValue}_new_report`;
    if (this.deleteLocalStorage()) {
      this.clearLocalStorage();
    }

    this.setFormData();
  }

  clearLocalStorage() {
    if (localStorage.getItem(this.localStorageKey) != null) {
      localStorage.removeItem(this.localStorageKey);
    }
  }

  getFormData() {
    const form = new FormData(this.formTarget);
    let data = [];

    for (var pair of form.entries()) {
      const name = pair[0];
      const value = pair[1];

      if (this.field_to_save(name, value)) {
        data.push([name, value]);
      }
    }

    return Object.fromEntries(data);
  }

  field_to_save(name, value) {
    const notAnAuthenticityToken = name !== "authenticity_token";
    const notAFile = !(value instanceof File);
    const notReportDate = !name.includes("report[date");

    return notAnAuthenticityToken && notAFile && notReportDate;
  }

  saveToLocalStorage() {
    const data = this.getFormData();
    localStorage.setItem(this.localStorageKey, JSON.stringify(data));
  }

  setFormData() {
    if (localStorage.getItem(this.localStorageKey) != null) {
      const data = JSON.parse(localStorage.getItem(this.localStorageKey));

      const form = this.formTarget;

      Object.entries(data).forEach((entry) => {
        let name = entry[0];
        let value = entry[1];
        let input = form.querySelector(`[name='${name}']`);
        input && (input.value = value);
      });
    }
  }

  deleteLocalStorage() {
    return document.getElementById("delete-local-storage");
  }
}
