import { Controller } from "@hotwired/stimulus";
import {
  SELECT_LIST_CLASSES,
  SELECT_MENU_CLASSES,
  SELECT_OPTION_CLASSES,
  SELECT_OPTION_SELECTED_CLASS
} from "select_menu_styles";

// Turns a <select> into a searchable combobox.
// The original <select> is kept hidden and stays the real form field,
// so all existing change-event listeners keep working.
export default class extends Controller {
  static values = {
    kindFilter: { type: String, default: "" }
  };

  connect() {
    this.options = Array.from(this.element.options)
      .filter((o) => o.value !== "")
      .map((o) => ({ value: o.value, label: o.text, kindId: o.dataset.kindId || "" }));

    this._buildUI();
    this._setDisplayFromSelect();
    this.element.style.display = "none";
    this._followKindFilter();
  }

  disconnect() {
    this.kindFilterElement?.removeEventListener("change", this.onKindFilterChange);
    this.scrollParent?.removeEventListener("scroll", this.onReposition, true);
    window.removeEventListener("resize", this.onReposition);
    document.removeEventListener("click", this._onDocClick, true);
    this.dropdown?.remove();
    this.wrapper?.remove();
    this.element.style.display = "";
  }

  _buildUI() {
    this.wrapper = document.createElement("div");
    this.wrapper.className = "combobox-wrapper relative";
    this.element.insertAdjacentElement("afterend", this.wrapper);

    this.input = document.createElement("input");
    this.input.type = "text";
    this.input.className =
      "block w-full rounded-lg border border-default bg-neutral-secondary-medium p-2.5 pr-9 text-sm text-heading focus:border-brand focus:ring-brand";
    this.input.placeholder = this.element.options[0]?.text || "Buscar…";
    this.input.autocomplete = "off";
    this.wrapper.appendChild(this.input);

    this.clearBtn = document.createElement("button");
    this.clearBtn.type = "button";
    this.clearBtn.className =
      "absolute right-2 top-1/2 hidden -translate-y-1/2 text-lg leading-none text-body-subtle hover:text-heading";
    this.clearBtn.innerHTML = "&times;";
    this.clearBtn.setAttribute("aria-label", "Limpiar");
    this.wrapper.appendChild(this.clearBtn);

    this.dropdown = document.createElement("ul");
    this.dropdown.className =
      `combobox-dropdown fixed z-[80] list-none p-0 ${SELECT_MENU_CLASSES} ${SELECT_LIST_CLASSES}`;
    document.body.appendChild(this.dropdown);

    this.onReposition = () => {
      if (!this.dropdown.classList.contains("hidden")) this._positionDropdown();
    };
    this.scrollParent = this._scrollParent();
    this.scrollParent.addEventListener("scroll", this.onReposition, true);
    window.addEventListener("resize", this.onReposition);

    this.input.addEventListener("input", () => this._onInput());
    this.input.addEventListener("focus", () => this._showDropdown(this.input.value));
    this.input.addEventListener("keydown", (e) => this._onKeydown(e));
    this.clearBtn.addEventListener("click", () => this._clear());
    document.addEventListener("click", this._onDocClick, true);
  }

  _onInput() {
    this._showDropdown(this.input.value);
    if (this.input.value === "") this._clear();
  }

  _followKindFilter() {
    if (!this.kindFilterValue) return;

    this.kindFilterElement = document.getElementById(this.kindFilterValue);
    if (!this.kindFilterElement) return;

    this.onKindFilterChange = () => {
      const kindId = this.kindFilterElement.value;
      const selected = this.options.find((option) => option.value === this.element.value);
      if (selected && kindId && selected.kindId !== kindId) this._clear();
      if (this.dropdown && !this.dropdown.classList.contains("hidden")) {
        this._showDropdown(this.input.value);
      }
    };
    this.kindFilterElement.addEventListener("change", this.onKindFilterChange);
  }

  _showDropdown(query) {
    const kindId = this.kindFilterElement?.value || "";
    const q = query.toLowerCase().trim();
    const filtered = this.options.filter((option) => {
      const kindMatch = !kindId || option.kindId === kindId;
      const textMatch = !q || option.label.toLowerCase().includes(q);
      return kindMatch && textMatch;
    });

    this.dropdown.innerHTML = "";
    if (filtered.length === 0) {
      const li = document.createElement("li");
      li.className = "px-4 py-2 text-sm text-body-subtle";
      li.textContent = "Sin resultados";
      this.dropdown.appendChild(li);
    } else {
      filtered.forEach((opt) => {
        const li = document.createElement("li");
        li.className =
          `combobox-option cursor-pointer ${SELECT_OPTION_CLASSES}` +
          (opt.value === this.element.value ? ` ${SELECT_OPTION_SELECTED_CLASS}` : "");
        li.textContent = opt.label;
        li.dataset.value = opt.value;
        li.addEventListener("mousedown", (e) => {
          e.preventDefault();
          this._select(opt);
        });
        this.dropdown.appendChild(li);
      });
    }
    this._positionDropdown();
    this.dropdown.classList.remove("hidden");
  }

  _positionDropdown() {
    const rect = this.input.getBoundingClientRect();
    const gap = 4;
    const preferred = 224;
    const spaceBelow = window.innerHeight - rect.bottom - gap - 8;
    const spaceAbove = rect.top - gap - 8;
    const openUp = spaceBelow < 160 && spaceAbove > spaceBelow;
    const maxHeight = Math.max(80, Math.min(preferred, openUp ? spaceAbove : spaceBelow));

    this.dropdown.style.zIndex = "80";
    this.dropdown.style.left = `${rect.left}px`;
    this.dropdown.style.width = `${rect.width}px`;
    this.dropdown.style.maxHeight = `${maxHeight}px`;

    if (openUp) {
      this.dropdown.style.top = "auto";
      this.dropdown.style.bottom = `${window.innerHeight - rect.top + gap}px`;
    } else {
      this.dropdown.style.bottom = "auto";
      this.dropdown.style.top = `${rect.bottom + gap}px`;
    }
  }

  _scrollParent() {
    let node = this.input.parentElement;
    while (node && node !== document.body) {
      const overflow = getComputedStyle(node).overflowY;
      if (overflow === "auto" || overflow === "scroll") return node;
      node = node.parentElement;
    }
    return window;
  }

  _select(opt) {
    this.input.value = opt.label;
    this.element.value = opt.value;
    this.clearBtn.classList.remove("hidden");
    this._hideDropdown();
    this.element.dispatchEvent(new Event("change", { bubbles: true }));
  }

  _clear() {
    this.input.value = "";
    this.element.value = "";
    this.clearBtn.classList.add("hidden");
    this._hideDropdown();
    this.element.dispatchEvent(new Event("change", { bubbles: true }));
  }

  _hideDropdown() {
    this.dropdown.classList.add("hidden");
  }

  _setDisplayFromSelect() {
    const selected = this.options.find((o) => o.value === this.element.value);
    if (selected) {
      this.input.value = selected.label;
      this.clearBtn.classList.remove("hidden");
    }
  }

  _onKeydown(e) {
    const items = this.dropdown.querySelectorAll(".combobox-option");
    const activeIdx = Array.from(items).findIndex((i) =>
      i.classList.contains("combobox-highlighted")
    );

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this._highlight(items, activeIdx + 1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this._highlight(items, activeIdx - 1);
    } else if (e.key === "Enter" && activeIdx >= 0) {
      e.preventDefault();
      const val = items[activeIdx].dataset.value;
      const opt = this.options.find((o) => o.value === val);
      if (opt) this._select(opt);
    } else if (e.key === "Escape") {
      this._hideDropdown();
    }
  }

  _highlight(items, idx) {
    items.forEach((i) => i.classList.remove("combobox-highlighted", SELECT_OPTION_SELECTED_CLASS));
    const target = items[Math.max(0, Math.min(idx, items.length - 1))];
    if (target) {
      target.classList.add("combobox-highlighted", SELECT_OPTION_SELECTED_CLASS);
      target.scrollIntoView({ block: "nearest" });
    }
  }

  _onDocClick = (e) => {
    if (this.wrapper?.contains(e.target) || this.dropdown?.contains(e.target)) return;
    this._hideDropdown();
  };
}
