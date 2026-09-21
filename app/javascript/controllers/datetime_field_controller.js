import { Controller } from "@hotwired/stimulus";
import { formatIsoDate, parseIsoDate } from "controllers/date_format";

// Combines a Flowbite datepicker and a native time input into one datetime
// param. The offset comes from the app time zone so Rails does not read the
// clock time as UTC.
export default class extends Controller {
  static targets = ["date", "time", "output"];
  static values = { offset: String };

  connect() {
    this.onDateChanged = () => this.sync();
    this.dateTarget.addEventListener("changeDate", this.onDateChanged);
  }

  disconnect() {
    this.dateTarget.removeEventListener("changeDate", this.onDateChanged);
  }

  sync() {
    const iso = this.#isoDate();
    if (!iso) {
      this.outputTarget.value = "";
      return;
    }

    const time = (this.timeTarget.value || "00:00").slice(0, 5);
    this.outputTarget.value = `${iso}T${time}:00${this.offsetValue}`;
  }

  #isoDate() {
    const picked = this.dateTarget.datepicker?.getDate();
    if (picked instanceof Date && !Number.isNaN(picked.getTime())) return formatIsoDate(picked);
    if (this.dateTarget.dataset.isoDate) return this.dateTarget.dataset.isoDate;

    const parsed = parseIsoDate(this.dateTarget.value);
    return parsed ? formatIsoDate(parsed) : "";
  }
}
