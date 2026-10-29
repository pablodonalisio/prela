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
    const data = {};

    for (const [name, value] of form.entries()) {
      if (!this.field_to_save(name, value)) continue;

      if (name.endsWith("[]")) {
        if (value === "") continue;

        data[name] ||= [];
        data[name].push(value);
      } else {
        data[name] = value;
      }
    }

    return data;
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
    if (localStorage.getItem(this.localStorageKey) == null) return;
    if (!this.hasFormTarget) return;

    const data = JSON.parse(localStorage.getItem(this.localStorageKey));
    const form = this.formTarget;

    Object.entries(data).forEach(([name, value]) => {
      if (name.endsWith("[]")) {
        this.restoreCheckboxes(form, name, value);
        return;
      }

      const input = form.querySelector(`[name='${name}']`);
      if (input) input.value = value;
    });
  }

  restoreCheckboxes(form, name, value) {
    const values = (Array.isArray(value) ? value : [value]).map(String).filter((item) => item !== "");
    const inputs = form.querySelectorAll(`[name='${name}']`);

    inputs.forEach((input) => {
      if (input.type === "checkbox") input.checked = values.includes(input.value);
    });
  }

  deleteLocalStorage() {
    return document.getElementById("delete-local-storage");
  }
}
