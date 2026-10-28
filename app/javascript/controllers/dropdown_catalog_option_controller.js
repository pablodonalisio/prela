import { Controller } from "@hotwired/stimulus";

// A dropdown list created from a template cell arrives as a turbo stream.
// Every cell select, including ones still inside <template> markup, gains the
// new option, and the cell that opened the modal selects it.
export default class extends Controller {
  static values = {id: Number, name: String, labels: String};

  connect() {
    this.#addOption(document);

    const pending = document.querySelector("[data-pending-dropdown-cell]");
    const select = pending?.querySelector('[data-name="table_dropdown_id"]');
    if (select) {
      select.value = String(this.idValue);
      select.dispatchEvent(new Event("change", {bubbles: true}));
      delete pending.dataset.pendingDropdownCell;
    }

    this.element.remove();
  }

  #addOption(root) {
    root.querySelectorAll?.('select[data-name="table_dropdown_id"]').forEach((select) => {
      const value = String(this.idValue);
      if ([...select.options].some((option) => option.value === value)) return;

      const option = document.createElement("option");
      option.value = value;
      option.textContent = this.nameValue;
      if (this.labelsValue) option.dataset.labels = this.labelsValue;
      select.appendChild(option);
    });
    root.querySelectorAll?.("[data-dropdown-empty]").forEach((hint) => {
      hint.classList.add("hidden");
    });
    root.querySelectorAll?.("template").forEach((template) => this.#addOption(template.content));
  }
}
