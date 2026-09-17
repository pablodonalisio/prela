import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "recurringInput",
    "intervalFields",
    "kindSelect",
    "intervalInput",
    "intervalUnitInput"
  ];
  static values = {
    recurringMap: Object,
    intervalDefaultsMap: Object,
    recurring: Boolean
  };

  connect() {
    this.syncFields();
  }

  toggle() {
    this.syncFields();
  }

  kindChanged() {
    this.syncFields();
  }

  syncFields() {
    const recurring = this.recurringForCurrentSelection();
    this.syncIntervalFields(recurring);
    this.syncIntervalDefaults(recurring);
  }

  syncIntervalFields(recurring) {
    if (!this.hasIntervalFieldsTarget) return;

    this.intervalFieldsTarget.classList.toggle("hidden", !recurring);
  }

  syncIntervalDefaults(recurring) {
    if (!recurring || !this.hasKindSelectTarget || !this.hasIntervalDefaultsMapValue) return;

    const defaults = this.intervalDefaultsMapValue[this.kindSelectTarget.value];
    if (!defaults) return;

    if (this.hasIntervalInputTarget && defaults.interval != null) {
      this.intervalInputTarget.value = defaults.interval;
    }

    if (this.hasIntervalUnitInputTarget && defaults.interval_unit != null) {
      this.intervalUnitInputTarget.value = defaults.interval_unit;
    }
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
