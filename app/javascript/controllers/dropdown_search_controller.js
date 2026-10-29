import { Controller } from "@hotwired/stimulus";

// Searchable checkbox menu. It stays in normal flow under the button so a modal
// can scroll to it. Checked items stay on removable chips.
export default class extends Controller {
  static targets = ["button", "label", "menu", "search", "item", "empty", "chips", "kind"];
  static values = {
    kindField: { type: String, default: "" }
  };

  connect() {
    if (!this.hasMenuTarget || !this.hasSearchTarget) return;

    this.menu = this.menuTarget;
    this.searchInput = this.searchTarget;
    this.kindSelect = this.hasKindTarget ? this.kindTarget : null;
    this.emptyMessage = this.hasEmptyTarget ? this.emptyTarget : null;

    this._initDropdown();

    this.onSearch = () => this._filter();
    this.onSearchKeydown = (event) => {
      if (event.key === "Enter") event.preventDefault();
    };
    this.onChange = () => this._syncLabel();
    this.onKindChange = () => this._filter();
    this.searchInput.addEventListener("input", this.onSearch);
    this.searchInput.addEventListener("keydown", this.onSearchKeydown);
    this.menu.addEventListener("change", this.onChange);
    this.kindSelect?.addEventListener("change", this.onKindChange);
    this._followKindField();
    this._syncLabel();
  }

  disconnect() {
    if (!this.searchInput) return;

    this.searchInput.removeEventListener("input", this.onSearch);
    this.searchInput.removeEventListener("keydown", this.onSearchKeydown);
    this.menu.removeEventListener("change", this.onChange);
    this.kindSelect?.removeEventListener("change", this.onKindChange);
    this.kindSelectElement?.removeEventListener("change", this.onKindFieldChange);
    this.buttonTarget.removeEventListener("click", this.onButtonClick);
    document.removeEventListener("click", this.onDocumentClick);
  }

  filter() {
    this._filter();
  }

  remove(event) {
    const button = event.target.closest("button[data-value]");
    if (!button || !this.hasChipsTarget || !this.chipsTarget.contains(button)) return;

    event.preventDefault();
    const checkbox = this.menu.querySelector(`input[type="checkbox"][value="${CSS.escape(button.dataset.value)}"]`);
    if (!checkbox) return;

    checkbox.checked = false;
    this._syncLabel();
  }

  _initDropdown() {
    this.onButtonClick = () => {
      if (this.menu.classList.contains("hidden")) this._show();
      else this._hide();
    };
    this.onDocumentClick = (event) => {
      if (this.menu.classList.contains("hidden")) return;
      if (this.element.contains(event.target)) return;
      if (event.target.closest?.(".search-dropdown-popover")) return;

      this._hide();
    };
    this.buttonTarget.addEventListener("click", this.onButtonClick);
    document.addEventListener("click", this.onDocumentClick);
  }

  _show() {
    this.menu.classList.remove("hidden");
    this.searchInput.value = "";
    this._filter();
    this.searchInput.focus({preventScroll: true});
    this._revealMenu();
  }

  _hide() {
    this.menu.classList.add("hidden");
    this._hideKindMenu();
  }

  // The menu stays in the modal, under the button. Scroll the modal so the
  // whole list is reachable instead of hanging off the screen.
  _revealMenu() {
    const scroller = this._scrollParent();
    if (!scroller) {
      this.menu.scrollIntoView({block: "nearest"});
      return;
    }

    const menuRect = this.menu.getBoundingClientRect();
    const scrollerRect = scroller.getBoundingClientRect();
    const hiddenBelow = menuRect.bottom - scrollerRect.bottom + 8;
    if (hiddenBelow <= 0) return;

    const roomUntilMenuTop = menuRect.top - scrollerRect.top;
    scroller.scrollBy({top: Math.min(hiddenBelow, Math.max(0, roomUntilMenuTop))});
  }

  _scrollParent() {
    let node = this.buttonTarget.parentElement;
    while (node && node !== document.body) {
      const overflow = getComputedStyle(node).overflowY;
      if (overflow === "auto" || overflow === "scroll") return node;
      node = node.parentElement;
    }
    return null;
  }

  _followKindField() {
    if (!this.kindSelect || !this.kindFieldValue) return;

    this.kindSelectElement = this.element.closest("form")?.querySelector(`select[name="${this.kindFieldValue}"]`);
    if (!this.kindSelectElement) return;

    this.onKindFieldChange = () => this._applyKindFromForm();
    this.kindSelectElement.addEventListener("change", this.onKindFieldChange);
    this._applyKindFromForm();
  }

  _applyKindFromForm() {
    const value = this.kindSelectElement.value;
    const known = Array.from(this.kindSelect.options).some((option) => option.value === value);
    this.kindSelect.value = known ? value : "";
    this.kindSelect.dispatchEvent(new Event("change", {bubbles: true}));
  }

  _hideKindMenu() {
    if (!this.menu.id) return;

    document.querySelectorAll(`[data-search-dropdown="${this.menu.id}"]`).forEach((menu) => {
      window.FlowbiteInstances?.getInstance?.("Dropdown", menu.id)?.hide();
    });
  }

  _filter() {
    const tokens = this._normalize(this.searchInput.value).split(/\s+/).filter(Boolean);
    const kindId = this.kindSelect?.value || "";
    let visible = 0;

    this.menu.querySelectorAll("[data-dropdown-search-target='item']").forEach((item) => {
      const kindMatch = !kindId || item.dataset.kindId === kindId;
      const label = this._normalize(item.dataset.label);
      const match = kindMatch && tokens.every((token) => label.includes(token));
      item.classList.toggle("hidden", !match);
      if (match) visible += 1;
    });

    this.emptyMessage?.classList.toggle("hidden", visible > 0);
  }

  _normalize(value) {
    return value.toString().normalize("NFD").replace(/\p{Diacritic}/gu, "").toLowerCase().trim();
  }

  _syncLabel() {
    const selected = [...this.menu.querySelectorAll("[data-dropdown-search-target='item']")].flatMap((item) => {
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
