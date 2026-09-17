import { Controller } from "@hotwired/stimulus";

// Turns a <select> into a searchable combobox.
// The original <select> is kept hidden and stays the real form field,
// so all existing change-event listeners keep working.
export default class extends Controller {
  connect() {
    this.options = Array.from(this.element.options)
      .filter((o) => o.value !== "")
      .map((o) => ({ value: o.value, label: o.text }));

    this._buildUI();
    this._setDisplayFromSelect();
    this.element.style.display = "none";
  }

  disconnect() {
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
      "block w-full rounded-lg border border-default bg-neutral-secondary-soft p-2.5 pr-9 text-sm text-heading focus:border-brand focus:ring-brand";
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
      "combobox-dropdown absolute left-0 top-full z-50 mt-1 hidden max-h-56 w-full list-none overflow-y-auto rounded-lg border border-default bg-neutral-primary p-0 shadow-lg";
    this.wrapper.appendChild(this.dropdown);

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

  _showDropdown(query) {
    const q = query.toLowerCase().trim();
    const filtered = q
      ? this.options.filter((o) => o.label.toLowerCase().includes(q))
      : this.options;

    this.dropdown.innerHTML = "";
    if (filtered.length === 0) {
      const li = document.createElement("li");
      li.className = "px-3 py-2 text-sm text-body-subtle";
      li.textContent = "Sin resultados";
      this.dropdown.appendChild(li);
    } else {
      filtered.forEach((opt) => {
        const li = document.createElement("li");
        li.className =
          "combobox-option cursor-pointer px-3 py-2 text-sm text-heading hover:bg-neutral-tertiary" +
          (opt.value === this.element.value ? " bg-brand text-white hover:bg-brand-strong" : "");
        li.textContent = opt.label;
        li.dataset.value = opt.value;
        li.addEventListener("mousedown", (e) => {
          e.preventDefault();
          this._select(opt);
        });
        this.dropdown.appendChild(li);
      });
    }
    this.dropdown.classList.remove("hidden");
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
    items.forEach((i) => i.classList.remove("combobox-highlighted", "bg-brand", "text-white"));
    const target = items[Math.max(0, Math.min(idx, items.length - 1))];
    if (target) {
      target.classList.add("combobox-highlighted", "bg-brand", "text-white");
      target.scrollIntoView({ block: "nearest" });
    }
  }

  _onDocClick = (e) => {
    if (!this.wrapper?.contains(e.target)) this._hideDropdown();
  };
}
