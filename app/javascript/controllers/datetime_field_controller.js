import { Controller } from "@hotwired/stimulus";
import { formatIsoDate, parseIsoDate } from "controllers/date_format";

// Combines a Flowbite datepicker and a 24-hour time field into one datetime
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

    const time = this.#time();
    if (!time) return;

    this.outputTarget.value = `${iso}T${time}:00${this.offsetValue}`;
  }

  normalizeTime() {
    const normalized = normalize24HourTime(this.timeTarget.value);
    if (normalized) this.timeTarget.value = normalized;
    this.sync();
  }

  #time() {
    return normalize24HourTime(this.timeTarget.value) || (this.timeTarget.value.trim() === "" ? "00:00" : "");
  }

  #isoDate() {
    const picked = this.dateTarget.datepicker?.getDate();
    if (picked instanceof Date && !Number.isNaN(picked.getTime())) return formatIsoDate(picked);
    if (this.dateTarget.dataset.isoDate) return this.dateTarget.dataset.isoDate;

    const parsed = parseIsoDate(this.dateTarget.value);
    return parsed ? formatIsoDate(parsed) : "";
  }
}

function normalize24HourTime(value) {
  const match = /^(\d{1,2}):(\d{2})$/.exec((value || "").trim());
  if (!match) return "";

  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  if (hours > 23 || minutes > 59) return "";

  return `${String(hours).padStart(2, "0")}:${match[2]}`;
}
