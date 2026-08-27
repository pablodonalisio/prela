import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["recurringInput", "intervalFields", "kindSelect"];
  static values = {
    recurringMap: Object,
    recurring: Boolean
  };

  connect() {
    this.syncIntervalFields();
  }

  toggle() {
    this.syncIntervalFields();
  }

  kindChanged() {
    this.syncIntervalFields();
  }

  syncIntervalFields() {
    if (!this.hasIntervalFieldsTarget) return;

    const recurring = this.recurringForCurrentSelection();
    this.intervalFieldsTarget.classList.toggle("d-none", !recurring);
  }

  recurringForCurrentSelection() {
    if (this.hasRecurringInputTarget) {
      return this.recurringInputTarget.checked;
    }

    if (this.hasKindSelectTarget && this.hasRecurringMapValue) {
      const kindId = this.kindSelectTarget.value;
      return Boolean(this.recurringMapValue[kindId]);
    }

    if (this.hasRecurringValue) {
      return this.recurringValue;
    }

    return true;
  }
}
