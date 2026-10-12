import { Controller } from "@hotwired/stimulus";

// Flowbite dropdown with search for the technician field inside the schedule modal.
export default class extends Controller {
  static targets = ["button", "label", "menu", "search", "item", "empty"];

  connect() {
    this._initDropdown();

    this.onSearch = () => this._filter();
    this.onSearchKeydown = (event) => {
      if (event.key === "Enter") event.preventDefault();
    };
    this.onChange = () => this._syncLabel();
    this.searchTarget.addEventListener("input", this.onSearch);
    this.searchTarget.addEventListener("keydown", this.onSearchKeydown);
    this.menuTarget.addEventListener("change", this.onChange);
    this._syncLabel();
  }

  disconnect() {
    this.searchTarget.removeEventListener("input", this.onSearch);
    this.searchTarget.removeEventListener("keydown", this.onSearchKeydown);
    this.menuTarget.removeEventListener("change", this.onChange);
    this.dropdown?.destroyAndRemoveInstance?.();
    this.dropdown = null;
  }

  _initDropdown() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown) return;

    this.dropdown = new Dropdown(this.menuTarget, this.buttonTarget, {
      placement: "bottom-start",
      triggerType: "click",
      offsetDistance: 8,
      onShow: () => {
        this._matchButtonWidth();
        this.searchTarget.value = "";
        this._filter();
        this.searchTarget.focus();
      }
    });
  }

  _matchButtonWidth() {
    const width = `${this.buttonTarget.offsetWidth}px`;
    this.menuTarget.style.width = width;
    this.menuTarget.style.minWidth = width;
    this.menuTarget.style.maxWidth = width;
  }

  _filter() {
    const query = this.searchTarget.value.toLowerCase().trim();
    let visible = 0;

    this.itemTargets.forEach((item) => {
      const match = item.dataset.label.toLowerCase().includes(query);
      item.classList.toggle("hidden", !match);
      if (match) visible += 1;
    });

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible > 0);
  }

  _syncLabel() {
    const selected = this.itemTargets
      .map((item) => item.querySelector("input[type='checkbox']"))
      .filter((input) => input?.checked)
      .map((input) => input.dataset.email);
    this.labelTarget.textContent = selected.length ? selected.join(", ") : "Técnicos";
    this.labelTarget.classList.toggle("text-body-subtle", selected.length === 0);
  }
}
