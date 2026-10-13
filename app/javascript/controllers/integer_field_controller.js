import { Controller } from "@hotwired/stimulus";

// Whole numbers only. Letters, commas and periods never stay in the field,
// including when pasted. A leading minus is allowed.
export default class extends Controller {
  block(event) {
    if (!this.active() || !event.data) return;
    if (this.allowedInsertion(event.data)) return;

    event.preventDefault();
  }

  filter() {
    if (!this.active()) return;

    const input = this.element;
    const cleaned = this.clean(input.value);
    if (cleaned === input.value) return;

    const cursor = input.selectionStart ?? cleaned.length;
    const prefix = this.clean(input.value.slice(0, cursor));
    input.value = cleaned;
    input.setSelectionRange(prefix.length, prefix.length);
  }

  active() {
    const cell = this.element.closest("[data-cell]");
    if (!cell) return true;

    return cell.querySelector("[data-name='value_type']")?.value === "integer";
  }

  allowedInsertion(data) {
    if (/^\d+$/.test(data)) return true;

    const input = this.element;
    return data === "-" && (input.selectionStart ?? 0) === 0 && !input.value.includes("-");
  }

  clean(value) {
    const negative = value.trimStart().startsWith("-");
    const digits = value.replace(/\D/g, "");
    return negative ? `-${digits}` : digits;
  }
}
