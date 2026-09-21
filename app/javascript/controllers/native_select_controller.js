import { Controller } from "@hotwired/stimulus";
import {
  SELECT_BUTTON_CLASSES,
  SELECT_LIST_CLASSES,
  SELECT_MENU_CLASSES,
  SELECT_OPTION_CLASSES,
  SELECT_OPTION_SELECTED_CLASS
} from "select_menu_styles";

// Replaces the OS-painted <select> popup with the same Flowbite dropdown
// surface used by shared/select_dropdown (Cliente / Tipo de servicio).
export default class extends Controller {
  connect() {
    this.upgrades = new Map();
    this._upgradeTree(this.element);
    this.observer = new MutationObserver((mutations) => this._onMutations(mutations));
    this.observer.observe(this.element, {childList: true, subtree: true});
  }

  disconnect() {
    this.observer?.disconnect();
    this.upgrades.forEach((upgrade) => upgrade.destroy());
    this.upgrades.clear();
  }

  _onMutations(mutations) {
    for (const mutation of mutations) {
      mutation.addedNodes.forEach((node) => {
        if (node.nodeType === 1) this._upgradeTree(node);
      });
      mutation.removedNodes.forEach((node) => {
        if (node.nodeType === 1) this._teardownTree(node);
      });
    }
  }

  _upgradeTree(root) {
    if (root.matches?.("select")) this._upgrade(root);
    root.querySelectorAll?.("select").forEach((select) => this._upgrade(select));
  }

  _teardownTree(root) {
    this.upgrades.forEach((upgrade, select) => {
      if (root === select || root.contains?.(select) || root === upgrade.wrapper) {
        upgrade.destroy();
        this.upgrades.delete(select);
      }
    });
  }

  _upgrade(select) {
    if (!this._shouldUpgrade(select)) return;

    const upgrade = new NativeSelectUpgrade(select);
    this.upgrades.set(select, upgrade);
  }

  _shouldUpgrade(select) {
    if (!(select instanceof HTMLSelectElement)) return false;
    if (select.multiple || Number(select.size) > 1) return false;
    if (select.dataset.nativeSelectSkip != null) return false;
    if (this.upgrades.has(select)) return false;
    const controllers = select.getAttribute("data-controller") || "";
    if (controllers.split(/\s+/).includes("searchable-select")) return false;
    return true;
  }
}

class NativeSelectUpgrade {
  constructor(select) {
    this.select = select;
    this.id = `native-select-${crypto.randomUUID()}`;
    this._build();
    this._bind();
    this._initDropdown();
  }

  destroy() {
    this.optionsObserver?.disconnect();
    this.select.removeEventListener("change", this.onSelectChange);
    this.button?.removeEventListener("click", this.onButtonClick);
    this.dropdown?.destroyAndRemoveInstance?.();
    this.dropdown = null;
    this.menu?.remove();
    this.wrapper?.remove();
    this.select.classList.remove("hidden");
    this.select.removeAttribute("aria-hidden");
    this.select.removeAttribute("tabindex");
    if (this.select.dataset.nativeSelectOriginalId) {
      this.select.id = this.select.dataset.nativeSelectOriginalId;
      delete this.select.dataset.nativeSelectOriginalId;
    }
  }

  _build() {
    this.select.classList.add("hidden");
    this.select.setAttribute("aria-hidden", "true");
    this.select.setAttribute("tabindex", "-1");

    this.wrapper = document.createElement("div");
    this.wrapper.className = "relative w-full";
    this.select.insertAdjacentElement("afterend", this.wrapper);

    this.button = document.createElement("button");
    this.button.type = "button";
    this.button.id = this.select.id || `${this.id}-button`;
    if (this.select.id) {
      this.select.dataset.nativeSelectOriginalId = this.select.id;
      this.select.removeAttribute("id");
    }
    this.button.className = SELECT_BUTTON_CLASSES;
    this.button.setAttribute("aria-haspopup", "listbox");
    this.button.setAttribute("aria-expanded", "false");
    this.button.disabled = this.select.disabled;
    this.button.innerHTML =
      `<span class="truncate"></span><i class="fa-solid fa-chevron-down ms-2 text-xs text-body-subtle" aria-hidden="true"></i>`;
    this.label = this.button.querySelector("span");
    this.wrapper.appendChild(this.button);

    this.menu = document.createElement("div");
    this.menu.id = this.id;
    this.menu.className = `${SELECT_MENU_CLASSES} !z-[70]`;
    this.list = document.createElement("ul");
    this.list.className = SELECT_LIST_CLASSES;
    this.list.setAttribute("role", "listbox");
    this.menu.appendChild(this.list);
    document.body.appendChild(this.menu);

    this._rebuildOptions();
    this._syncLabel();
  }

  _bind() {
    this.onSelectChange = () => {
      this._syncLabel();
      this._highlightSelected();
    };
    this.select.addEventListener("change", this.onSelectChange);

    this.onButtonClick = () => this._syncWidth();
    this.button.addEventListener("click", this.onButtonClick);

    this.optionsObserver = new MutationObserver(() => {
      this._rebuildOptions();
      this._syncLabel();
    });
    this.optionsObserver.observe(this.select, {childList: true, subtree: true});
  }

  _initDropdown() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown) return;

    this.dropdown = new Dropdown(this.menu, this.button, {
      placement: "bottom-start",
      triggerType: "click",
      offsetDistance: 8
    });
  }

  _rebuildOptions() {
    this.list.innerHTML = "";
    Array.from(this.select.options).forEach((option) => {
      const li = document.createElement("li");
      const button = document.createElement("button");
      button.type = "button";
      button.className = SELECT_OPTION_CLASSES;
      button.textContent = option.text;
      button.dataset.value = option.value;
      button.disabled = option.disabled;
      if (option.selected) button.classList.add(SELECT_OPTION_SELECTED_CLASS);
      button.addEventListener("click", () => this._choose(option.value, option.text));
      li.appendChild(button);
      this.list.appendChild(li);
    });
  }

  _choose(value, label) {
    if (this.select.value !== value) {
      this.select.value = value;
      this.select.dispatchEvent(new Event("change", {bubbles: true}));
    }
    this.label.textContent = label;
    this._highlightSelected();
    this.dropdown?.hide();
  }

  _syncLabel() {
    const selected = this.select.selectedOptions[0];
    this.label.textContent = selected?.text || "";
    this.button.disabled = this.select.disabled;
  }

  _highlightSelected() {
    this.list.querySelectorAll("button").forEach((button) => {
      button.classList.toggle(
        SELECT_OPTION_SELECTED_CLASS,
        button.dataset.value === this.select.value
      );
    });
  }

  _syncWidth() {
    this.menu.style.minWidth = `${this.button.offsetWidth}px`;
  }
}
