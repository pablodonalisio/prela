import { Controller } from "@hotwired/stimulus";

const TYPE_LABELS = {
  string: "Texto",
  integer: "Número entero",
  float: "Número decimal",
  date: "Fecha",
  boolean: "Booleano",
};

// Rebuilds the visible table when the row or column count changes, and keeps
// each cell's options inside a Flowbite dropdown.
export default class extends Controller {
  static targets = ["rows", "columns", "body", "cellTemplate", "labelTemplate"];
  static values = {
    maxRows: {type: Number, default: 32},
    maxColumns: {type: Number, default: 10},
  };

  connect() {
    this.serial = 0;
    this.dropdowns = [];
    this.onKeydown = (event) => this.closeOnEscape(event);
    document.addEventListener("keydown", this.onKeydown);
    if (this.bodyTarget.querySelectorAll("[data-cell]").length === 0) {
      this.rebuild();
    } else {
      this.bodyTarget.querySelectorAll("[data-cell]").forEach((cell) => this.syncCell({target: cell}));
      this.mountDropdowns();
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown);
    this.destroyDropdowns();
  }

  closeOnEscape(event) {
    if (event.key !== "Escape") return;

    const inner = this.openInnerMenu();
    if (inner) {
      inner.hide();
      event.preventDefault();
      return;
    }

    const panels = this.openPanels();
    if (panels.length === 0) return;

    panels.forEach((dropdown) => dropdown.hide());
    event.preventDefault();
  }

  rebuild() {
    const rows = this.clamp(this.rowsTarget.value, 1, this.maxRowsValue);
    const columns = this.clamp(this.columnsTarget.value, 1, this.maxColumnsValue);
    this.rowsTarget.value = rows;
    this.columnsTarget.value = columns;

    const cells = this.collectCells();
    const labels = this.collectLabels();
    this.destroyDropdowns();
    this.bodyTarget.replaceChildren(this.buildTable(rows, columns, cells, labels));
    this.mountDropdowns();
  }

  prepareRadio(event) {
    const radio = this.radioFrom(event.target);
    if (!radio || radio.disabled) return;

    radio.dataset.wasChecked = radio.checked ? "true" : "false";
  }

  releaseRadio(event) {
    const radio = event.target;
    if (!(radio instanceof HTMLInputElement) || radio.type !== "radio" || radio.disabled) return;
    if (radio.dataset.wasChecked !== "true") {
      radio.closest("[data-cell]")?.querySelectorAll('input[type="radio"]').forEach((input) => {
        input.dataset.wasChecked = input === radio ? "true" : "false";
      });
      return;
    }

    radio.checked = false;
    radio.dataset.wasChecked = "false";
    this.syncCell({target: radio});
  }

  syncCell(event) {
    const cell = event.target.closest?.("[data-cell]") || event.target;
    if (!cell?.matches?.("[data-cell]")) return;

    const type = this.field(cell, "value_type")?.value;
    const metrics = this.checkbox(cell, "for_metrics");
    const numeric = type === "integer" || type === "float";
    if (metrics) {
      metrics.disabled = !numeric;
      if (!numeric) metrics.checked = false;
      metrics.closest("[data-metrics-row]")?.classList.toggle("cursor-not-allowed", !numeric);
      metrics.closest("[data-metrics-row]")?.classList.toggle("opacity-50", !numeric);
    }

    const fixedInput = this.checkbox(cell, "fixed");
    const fixable = type === "string" || type === "integer" || type === "float";
    if (fixedInput) {
      fixedInput.disabled = !fixable;
      if (!fixable) fixedInput.checked = false;
      fixedInput.closest("[data-fixed-row]")?.classList.toggle("cursor-not-allowed", !fixable);
      fixedInput.closest("[data-fixed-row]")?.classList.toggle("opacity-50", !fixable);
    }

    const booleanOptions = cell.querySelector("[data-boolean-options]");
    if (booleanOptions) {
      const booleanType = type === "boolean";
      booleanOptions.classList.toggle("hidden", !booleanType);
      booleanOptions.disabled = !booleanType;
    }

    const fixed = Boolean(fixedInput?.checked);
    const valueWrap = cell.querySelector("[data-value-wrap]");
    if (valueWrap) valueWrap.classList.toggle("hidden", !fixed);
    const value = this.field(cell, "value");
    if (value) {
      if (!fixed) value.value = "";
      if (type === "integer") {
        value.inputMode = "numeric";
        const cleaned = this.integerValue(value.value);
        if (cleaned !== value.value) value.value = cleaned;
      } else if (type === "float") {
        value.inputMode = "decimal";
      } else {
        value.removeAttribute("inputmode");
      }
    }

    const summary = cell.querySelector("[data-cell-summary]");
    if (summary) summary.textContent = this.summaryText(cell);
  }

  buildTable(rows, columns, cells, labels) {
    const table = document.createElement("table");
    table.className = "w-full border-collapse text-sm";

    const head = document.createElement("tr");
    head.appendChild(this.corner(labels));
    for (let column = 0; column < columns; column += 1) {
      const th = document.createElement("th");
      th.className = "min-w-36 border border-default p-2 align-top";
      th.appendChild(this.buildLabel("column", column, labels.get(`column_${column}`) || {}));
      head.appendChild(th);
    }
    const thead = document.createElement("thead");
    thead.appendChild(head);
    table.appendChild(thead);

    const tbody = document.createElement("tbody");
    for (let row = 0; row < rows; row += 1) {
      const tr = document.createElement("tr");
      const rowHeader = document.createElement("th");
      rowHeader.className = "min-w-36 border border-default p-2 align-top";
      rowHeader.appendChild(this.buildLabel("row", row, labels.get(`row_${row}`) || {}));
      tr.appendChild(rowHeader);

      for (let column = 0; column < columns; column += 1) {
        const td = document.createElement("td");
        td.className = "min-w-36 border border-default p-2 align-top";
        td.appendChild(this.buildCell(row, column, cells.get(`${row}_${column}`) || {}));
        tr.appendChild(td);
      }
      tbody.appendChild(tr);
    }
    table.appendChild(tbody);
    return table;
  }

  corner(labels) {
    const th = document.createElement("th");
    th.className = "min-w-36 border border-default p-2 align-top";
    th.appendChild(this.buildLabel("corner", 0, labels.get("corner_0") || {}));
    return th;
  }

  buildLabel(axis, position, saved) {
    const html = this.labelTemplateTarget.innerHTML
      .replaceAll("LABEL_INDEX", String(this.nextSerial()))
      .replaceAll("__AXIS__", axis)
      .replaceAll("__POSITION__", String(position));
    const label = this.fragment(html, "[data-label]");
    label.dataset.axis = axis;
    label.dataset.position = String(position);
    this.setField(label, "id", saved.id || "");
    this.setField(label, "axis", axis);
    this.setField(label, "position", String(position));
    this.setField(label, "_destroy", "0");
    this.setField(label, "label", saved.label || "");
    const input = this.field(label, "label");
    if (input) {
      if (axis === "column") {
        input.placeholder = "Encabezado";
        input.setAttribute("aria-label", `Encabezado de columna ${position + 1}`);
      } else if (axis === "corner") {
        input.placeholder = "Título";
        input.setAttribute("aria-label", "Título");
      } else {
        input.placeholder = "Fila";
        input.setAttribute("aria-label", `Nombre de fila ${position + 1}`);
      }
    }
    return label;
  }

  buildCell(row, column, saved) {
    const menuId = `cell-menu-${this.nextSerial()}`;
    const html = this.cellTemplateTarget.innerHTML
      .replaceAll("CELL_INDEX", String(this.nextSerial()))
      .replaceAll("__ROW__", String(row))
      .replaceAll("__COL__", String(column))
      .replaceAll("__MENU__", menuId);
    const cell = this.fragment(html, "[data-cell]");
    cell.dataset.row = String(row);
    cell.dataset.col = String(column);
    this.setField(cell, "id", saved.id || "");
    this.setField(cell, "row_index", String(row));
    this.setField(cell, "column_index", String(column));
    this.setField(cell, "_destroy", "0");
    this.setField(cell, "value_type", saved.valueType || "string");
    this.setField(cell, "value", saved.fixed ? saved.value || "" : "");
    const fixed = Boolean(saved.fixed);
    this.setCheckbox(cell, "fixed", fixed);
    this.setCheckbox(cell, "for_metrics", Boolean(saved.forMetrics) && !fixed);
    this.restoreBooleanOptions(cell, saved.booleanOptions || []);
    this.syncCell({target: cell});
    return cell;
  }

  collectCells() {
    const cells = new Map();
    this.bodyTarget.querySelectorAll("[data-cell]").forEach((cell) => {
      cells.set(`${cell.dataset.row}_${cell.dataset.col}`, {
        id: this.field(cell, "id")?.value || "",
        valueType: this.field(cell, "value_type")?.value || "string",
        value: this.field(cell, "value")?.value || "",
        forMetrics: Boolean(this.checkbox(cell, "for_metrics")?.checked),
        fixed: Boolean(this.checkbox(cell, "fixed")?.checked),
        booleanOptions: [...cell.querySelectorAll("[data-boolean-option]")].map((option) => ({
          id: this.field(option, "id")?.value || "",
          value: option.dataset.booleanValue,
          label: this.field(option, "label")?.value || "",
        })),
      });
    });
    return cells;
  }

  collectLabels() {
    const labels = new Map();
    this.bodyTarget.querySelectorAll("[data-label]").forEach((label) => {
      labels.set(`${label.dataset.axis}_${label.dataset.position}`, {
        id: this.field(label, "id")?.value || "",
        label: this.field(label, "label")?.value || "",
      });
    });
    return labels;
  }

  integerValue(value) {
    const negative = value.trimStart().startsWith("-");
    const digits = value.replace(/\D/g, "");
    return negative ? `-${digits}` : digits;
  }

  summaryText(cell) {
    const type = this.field(cell, "value_type")?.value || "string";
    const parts = [TYPE_LABELS[type] || type];
    const fixed = Boolean(this.checkbox(cell, "fixed")?.checked);
    const value = this.field(cell, "value")?.value || "";
    if (fixed && value) parts.push(value);
    if (this.checkbox(cell, "for_metrics")?.checked) parts.push("Métricas");
    return parts.join(" · ");
  }

  mountDropdowns() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown) return;

    const instances = window.FlowbiteInstances;
    this.bodyTarget.querySelectorAll("[data-cell-menu]").forEach((menu) => {
      const trigger = this.bodyTarget.querySelector(`[data-cell-trigger="${CSS.escape(menu.id)}"]`);
      if (!trigger) return;

      if (typeof instances?.instanceExists === "function" && instances.instanceExists("Dropdown", menu.id)) {
        instances.getInstance("Dropdown", menu.id)?.destroyAndRemoveInstance?.();
      }

      const dropdown = new Dropdown(
        menu,
        trigger,
        {placement: "bottom-start", ignoreClickOutsideClass: "cell-panel-popover"},
        {id: menu.id, override: true},
      );
      const placeBelowCell = () => {
        const popper = dropdown._popperInstance;
        if (!popper) return;

        popper.setOptions((options) => ({
          ...options,
          placement: "bottom-start",
          strategy: "fixed",
          modifiers: [
            ...(options.modifiers || []).filter((modifier) => modifier.name !== "flip" && modifier.name !== "preventOverflow"),
            {name: "flip", enabled: false},
            {name: "preventOverflow", enabled: false},
          ],
        })).then(() => {
          const overflow = menu.getBoundingClientRect().bottom - window.innerHeight + 16;
          if (overflow > 0) {
            window.scrollBy(0, overflow);
            popper.update();
          }
        });
      };
      placeBelowCell();
      trigger.addEventListener("click", () => requestAnimationFrame(placeBelowCell));
      this.dropdowns.push(dropdown);
    });
  }

  destroyDropdowns() {
    this.dropdowns.forEach((dropdown) => dropdown.destroyAndRemoveInstance?.());
    this.dropdowns = [];
  }

  fragment(html, selector) {
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html.trim();
    return wrapper.querySelector(selector);
  }

  field(root, name) {
    return root.querySelector(`[data-name="${name}"]`);
  }

  openPanels() {
    return [...this.bodyTarget.querySelectorAll("[data-cell-menu]")].flatMap((menu) => {
      const dropdown = window.FlowbiteInstances?.getInstance?.("Dropdown", menu.id);
      return dropdown?.isVisible?.() ? [dropdown] : [];
    });
  }

  openInnerMenu() {
    const menu = [...document.querySelectorAll(".cell-panel-popover")].find((element) => {
      const panel = element.dataset.cellPanel;
      if (!panel || !this.bodyTarget.querySelector(`#${CSS.escape(panel)}`)) return false;

      return window.FlowbiteInstances?.getInstance?.("Dropdown", element.id)?.isVisible?.();
    });
    return menu ? window.FlowbiteInstances.getInstance("Dropdown", menu.id) : null;
  }

  restoreBooleanOptions(cell, saved) {
    cell.querySelectorAll("[data-boolean-option]").forEach((option) => {
      const match = saved.find((item) => String(item.value) === option.dataset.booleanValue);
      if (!match) return;

      this.setField(option, "id", match.id || "");
      this.setField(option, "label", match.label || "");
    });
  }

  radioFrom(target) {
    if (target instanceof HTMLInputElement && target.type === "radio") return target;

    const label = target.closest?.("label");
    const id = label?.htmlFor;
    if (!id) return null;

    return label.closest("[data-cell]")?.querySelector(`#${CSS.escape(id)}`) || null;
  }

  checkbox(root, name) {
    return root.querySelector(`input[type="radio"][data-name="${name}"]`);
  }

  setField(root, name, value) {
    const input = this.field(root, name);
    if (input) input.value = value;
  }

  setCheckbox(root, name, checked) {
    const input = this.checkbox(root, name);
    if (input) input.checked = checked;
  }

  nextSerial() {
    this.serial += 1;
    return this.serial;
  }

  clamp(value, min, max) {
    const number = Number.parseInt(value, 10);
    if (Number.isNaN(number)) return min;
    return Math.min(Math.max(number, min), max);
  }
}
