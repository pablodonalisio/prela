import { Controller } from "@hotwired/stimulus";

// Flowbite dropdown with search. Checked items stay on removable chips and
// the button keeps its placeholder.
export default class extends Controller {
  static targets = ["button", "label", "menu", "search", "item", "empty", "chips", "kind"];
  static values = {
    kindField: { type: String, default: "" }
  };

  connect() {
    if (!this.hasSearchTarget) return;

    this._initDropdown();

    this.onSearch = () => this._filter();
    this.onSearchKeydown = (event) => {
      if (event.key === "Enter") event.preventDefault();
    };
    this.onChange = () => this._syncLabel();
    this.searchTarget.addEventListener("input", this.onSearch);
    this.searchTarget.addEventListener("keydown", this.onSearchKeydown);
    this.menuTarget.addEventListener("change", this.onChange);
    this._followKindField();
    this._syncLabel();
  }

  disconnect() {
    if (!this.hasSearchTarget) return;

    this.searchTarget.removeEventListener("input", this.onSearch);
    this.searchTarget.removeEventListener("keydown", this.onSearchKeydown);
    this.menuTarget.removeEventListener("change", this.onChange);
    this.kindSelectElement?.removeEventListener("change", this.onKindFieldChange);
    this.dropdown?.destroyAndRemoveInstance?.();
    this.dropdown = null;
  }

  filter() {
    this._filter();
  }

  remove(event) {
    const button = event.target.closest("button[data-value]");
    if (!button || !this.hasChipsTarget || !this.chipsTarget.contains(button)) return;

    event.preventDefault();
    const checkbox = this.element.querySelector(`input[type="checkbox"][value="${CSS.escape(button.dataset.value)}"]`);
    if (!checkbox) return;

    checkbox.checked = false;
    this._syncLabel();
  }

  _initDropdown() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown) return;

    this.dropdown = new Dropdown(this.menuTarget, this.buttonTarget, {
      placement: "bottom-start",
      triggerType: "click",
      offsetDistance: 8,
      ignoreClickOutsideClass: "search-dropdown-popover",
      onShow: () => {
        this._matchButtonWidth();
        this.searchTarget.value = "";
        this._filter();
        this.searchTarget.focus();
      },
      onHide: () => this._hideKindMenu()
    });
  }

  _matchButtonWidth() {
    const width = `${this.buttonTarget.offsetWidth}px`;
    this.menuTarget.style.width = width;
    this.menuTarget.style.minWidth = width;
    this.menuTarget.style.maxWidth = width;
  }

  _followKindField() {
    if (!this.hasKindTarget || !this.kindFieldValue) return;

    this.kindSelectElement = this.element.closest("form")?.querySelector(`select[name="${this.kindFieldValue}"]`);
    if (!this.kindSelectElement) return;

    this.onKindFieldChange = () => this._applyKindFromForm();
    this.kindSelectElement.addEventListener("change", this.onKindFieldChange);
    this._applyKindFromForm();
  }

  _applyKindFromForm() {
    const value = this.kindSelectElement.value;
    const known = Array.from(this.kindTarget.options).some((option) => option.value === value);
    this.kindTarget.value = known ? value : "";
    this.kindTarget.dispatchEvent(new Event("change", {bubbles: true}));
  }

  _hideKindMenu() {
    if (!this.menuTarget.id) return;

    document.querySelectorAll(`[data-search-dropdown="${this.menuTarget.id}"]`).forEach((menu) => {
      window.FlowbiteInstances?.getInstance?.("Dropdown", menu.id)?.hide();
    });
  }

  _filter() {
    const tokens = this._normalize(this.searchTarget.value).split(/\s+/).filter(Boolean);
    const kindId = this.hasKindTarget ? this.kindTarget.value : "";
    let visible = 0;

    this.itemTargets.forEach((item) => {
      const kindMatch = !kindId || item.dataset.kindId === kindId;
      const label = this._normalize(item.dataset.label);
      const match = kindMatch && tokens.every((token) => label.includes(token));
      item.classList.toggle("hidden", !match);
      if (match) visible += 1;
    });

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible > 0);
  }

  _normalize(value) {
    return value.toString().normalize("NFD").replace(/\p{Diacritic}/gu, "").toLowerCase().trim();
  }

  _syncLabel() {
    const selected = this.itemTargets.flatMap((item) => {
      const checkbox = item.querySelector("input[type='checkbox']");
      return checkbox?.checked ? [{ label: item.dataset.label, value: checkbox.value }] : [];
    });

    this._syncChips(selected);
    this.labelTarget.textContent = this.labelTarget.dataset.placeholder;
    this.labelTarget.classList.add("text-body-subtle");
  }

  _syncChips(selected) {
    if (!this.hasChipsTarget) return;

    this.chipsTarget.replaceChildren();
    selected.forEach(({ label, value }) => {
      const chip = document.createElement("span");
      chip.className = "inline-flex items-center gap-1 rounded-full bg-brand-soft px-2.5 py-0.5 text-xs font-medium text-fg-brand";
      chip.append(document.createTextNode(label));

      const button = document.createElement("button");
      button.type = "button";
      button.dataset.value = value;
      button.setAttribute("aria-label", `Quitar ${label}`);
      button.className = "leading-none";
      button.textContent = "×";
      chip.append(button);
      this.chipsTarget.append(chip);
    });
  }
}
