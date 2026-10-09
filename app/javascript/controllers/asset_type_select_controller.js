import { Controller } from "@hotwired/stimulus";

// Flowbite dropdown for Tipo de Activo. The menu is the same surface as
// shared/select_dropdown. It is moved to document.body so the modal's
// overflow does not clip it. data-dropdown-toggle stays in the markup;
// this controller takes over the Dropdown instance after portaling the menu,
// because Flowbite's frame-load init would bind it while it is still clipped.
export default class extends Controller {
  static targets = ["input", "label", "button", "menu", "addToggle", "addPanel"];

  connect() {
    this.menu = this.menuTarget;
    this.addToggle = this.addToggleTarget;
    this.addPanel = this.addPanelTarget;
    document.body.appendChild(this.menu);
    this._bindMenu();
    this._watchMenuVisibility();
    this._initDropdown();
    this.onFrameLoad = () => this._initDropdown();
    document.addEventListener("turbo:frame-load", this.onFrameLoad);
    this._bindFilterSync();
    this.syncWidth();

    if (this.element.dataset.adding === "true") {
      this._openAddPanel();
      requestAnimationFrame(() => {
        this.syncWidth();
        this.dropdown?.show();
        this.addPanel.querySelector("input[name='asset_type[name]']")?.focus();
      });
    }

    if (this.element.dataset.editing === "true") {
      const form = document.getElementById("edit_asset_type");
      if (form && this.element.dataset.editingUrl) form.action = this.element.dataset.editingUrl;
      requestAnimationFrame(() => {
        this.syncWidth();
        this.dropdown?.show();
        this.menu.querySelector("[data-asset-type-edit-panel]:not(.hidden) input[name='asset_type[name]']")?.focus();
      });
    }
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.onFrameLoad);
    this.filterForms?.forEach((form) => form.removeEventListener("submit", this.onFilterSync));
    this.menuObserver?.disconnect();
    this.dropdown?.destroyAndRemoveInstance?.();
    this.dropdown = null;
    this.menu?.remove();
    this.menu = null;
  }

  _bindFilterSync() {
    this.onFilterSync = (event) => this._copyFilterSelection(event.currentTarget);
    this.filterForms = ["new_asset_type", "edit_asset_type"]
      .map((id) => document.getElementById(id))
      .filter(Boolean);
    this.filterForms.forEach((form) => form.addEventListener("submit", this.onFilterSync));
  }

  _copyFilterSelection(form) {
    form.querySelectorAll("[data-filter-asset-type]").forEach((input) => input.remove());
    this._selectedFilterIds().forEach((id) => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "asset_type_ids[]";
      input.value = id;
      input.dataset.filterAssetType = "";
      form.appendChild(input);
    });
  }

  _selectedFilterIds() {
    return Array.from(
      document.querySelectorAll("#equipment_kind_filters input[name='asset_type_ids[]']:checked")
    ).map((input) => input.value);
  }

  syncWidth() {
    if (!this.hasButtonTarget || !this.menu) return;
    this.menu.style.minWidth = `${this.buttonTarget.offsetWidth}px`;
  }

  _bindMenu() {
    this.menu.addEventListener("click", (event) => {
      const destroyLink = event.target.closest("[data-asset-type-destroy]");
      if (destroyLink) {
        const url = new URL(destroyLink.href, window.location.origin);
        url.searchParams.set("selected_id", this.inputTarget.value);
        url.searchParams.delete("asset_type_ids[]");
        this._selectedFilterIds().forEach((id) => url.searchParams.append("asset_type_ids[]", id));
        destroyLink.href = `${url.pathname}${url.search}`;
        return;
      }

      const add = event.target.closest("[data-asset-type-add]");
      if (add) {
        event.preventDefault();
        this._openAddPanel();
        return;
      }

      const edit = event.target.closest("[data-asset-type-edit]");
      if (edit) {
        event.preventDefault();
        this._openEdit(edit);
        return;
      }

      const cancel = event.target.closest("[data-asset-type-cancel]");
      if (cancel) {
        event.preventDefault();
        this._resetPanels();
        return;
      }

      const choose = event.target.closest("[data-asset-type-choose]");
      if (choose) {
        event.preventDefault();
        this._choose(choose.dataset.value, choose.dataset.label);
      }
    });
  }

  _openAddPanel() {
    this._closeEditPanels();
    this.addToggle.classList.add("hidden");
    this.addPanel.classList.remove("hidden");
    this.addPanel.querySelector("input[name='asset_type[name]']")?.focus();
  }

  _openEdit(button) {
    const form = document.getElementById("edit_asset_type");
    if (form) form.action = button.dataset.editUrl;
    this.addToggle.classList.remove("hidden");
    this.addPanel.classList.add("hidden");
    this._closeEditPanels();

    const option = button.closest("[data-asset-type-option]");
    option.querySelector("[data-asset-type-row]")?.classList.add("hidden");
    const panel = option.querySelector("[data-asset-type-edit-panel]");
    panel.classList.remove("hidden");
    panel.querySelectorAll("input, button").forEach((field) => {
      field.disabled = false;
    });
    const input = panel.querySelector("input[name='asset_type[name]']");
    input?.focus();
    input?.select();
  }

  _watchMenuVisibility() {
    this.wasOpen = !this.menu.classList.contains("hidden");
    this.menuObserver = new MutationObserver(() => {
      const hidden = this.menu.classList.contains("hidden");
      if (this.wasOpen && hidden) this._resetPanels();
      this.wasOpen = !hidden;
    });
    this.menuObserver.observe(this.menu, {attributes: true, attributeFilter: ["class"]});
  }

  _resetPanels() {
    this._closeEditPanels();
    this.menu.querySelectorAll("[data-original-name]").forEach((input) => {
      input.value = input.dataset.originalName;
    });
    this.menu.querySelectorAll("[data-asset-type-edit-panel] .text-fg-danger, [data-asset-type-select-target='addPanel'] .text-fg-danger").forEach((error) => {
      error.remove();
    });
    this.addPanel.classList.add("hidden");
    this.addToggle.classList.remove("hidden");
    const addInput = this.addPanel.querySelector("input[name='asset_type[name]']");
    if (addInput) addInput.value = "";
  }

  _closeEditPanels() {
    this.menu.querySelectorAll("[data-asset-type-option]").forEach((option) => {
      option.querySelector("[data-asset-type-row]")?.classList.remove("hidden");
      const panel = option.querySelector("[data-asset-type-edit-panel]");
      if (!panel) return;
      panel.classList.add("hidden");
      panel.querySelectorAll("input, button").forEach((field) => {
        field.disabled = true;
      });
    });
  }

  _choose(value, label) {
    this.inputTarget.value = value ?? "";
    this.labelTarget.textContent = label ?? "";
    this.labelTarget.classList.toggle("text-body-subtle", !value);
    this.menu.querySelectorAll("[data-selected-mirror]").forEach((mirror) => {
      mirror.value = this.inputTarget.value;
    });
    this.inputTarget.dispatchEvent(new Event("change", {bubbles: true}));

    this.menu.querySelectorAll("[data-asset-type-option]").forEach((option) => {
      option.querySelector("[data-asset-type-row]")?.classList.toggle(
        "bg-neutral-tertiary-medium",
        option.dataset.value === this.inputTarget.value
      );
    });
    this.dropdown?.hide();
  }

  _initDropdown() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown || !this.menu || !this.hasButtonTarget) return;

    this.dropdown?.destroyAndRemoveInstance?.();
    const id = this.menu.id;
    const instances = window.FlowbiteInstances;
    if (id && typeof instances?.instanceExists === "function" && instances.instanceExists("Dropdown", id)) {
      instances.getInstance("Dropdown", id)?.destroyAndRemoveInstance?.();
    }

    // Keep Flowbite from binding a second dropdown on the pre-portal node.
    this.buttonTarget.removeAttribute("data-dropdown-toggle");

    this.dropdown = new Dropdown(this.menu, this.buttonTarget, {
      placement: "bottom-start",
      triggerType: "click",
      offsetDistance: 8
    });
  }
}
