import { Controller } from "@hotwired/stimulus";

// Native <select> popups are painted by the OS, so they never pick up Flowbite
// tokens. This controller keeps a hidden input as the real form field and uses
// Flowbite's dropdown for the visible menu.
export default class extends Controller {
  static targets = ["input", "label", "button", "menu", "option"];

  connect() {
    this.syncWidth();
  }

  syncWidth() {
    if (!this.hasButtonTarget || !this.hasMenuTarget) return;
    this.menuTarget.style.minWidth = `${this.buttonTarget.offsetWidth}px`;
  }

  choose(event) {
    const { value, label } = event.params;
    this.inputTarget.value = value ?? "";
    this.labelTarget.textContent = label;
    this._highlight(event.currentTarget);
    this._hideMenu();
  }

  _highlight(chosen) {
    this.optionTargets.forEach((option) => {
      option.classList.toggle("bg-neutral-tertiary-medium", option === chosen);
    });
  }

  _hideMenu() {
    const id = this.menuTarget.id;
    const instances = window.FlowbiteInstances;
    if (!id || !instances) return;
    if (typeof instances.instanceExists === "function" && !instances.instanceExists("Dropdown", id)) {
      return;
    }
    instances.getInstance("Dropdown", id)?.hide();
  }
}
