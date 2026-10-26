import { Controller } from "@hotwired/stimulus";
import Datepicker from "flowbite-datepicker";
import { formatDisplayDate, formatIsoDate, parseIsoDate } from "controllers/date_format";

// Spanish copy for flowbite-datepicker. The library ships English only;
// assigning onto Datepicker.locales mutates the shared locale table.
const SPANISH = {
  days: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
  daysShort: ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"],
  daysMin: ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa"],
  months: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
  monthsShort: ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"],
  today: "Hoy",
  monthsTitle: "Meses",
  clear: "Borrar",
  weekStart: 1,
  format: "dd/mm/yyyy",
  titleFormat: "MM y"
};

// Replaces native date inputs with the Flowbite datepicker. The visible field
// shows dd/mm/yyyy; a hidden sibling keeps yyyy-mm-dd so Rails date casting
// stays unambiguous.
export default class extends Controller {
  connect() {
    if (!Datepicker.locales.es) Datepicker.locales.es = SPANISH;

    this.bound = new WeakSet();
    this.#upgradeTree(this.element);
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1) this.#upgradeTree(node);
        });
        mutation.removedNodes.forEach((node) => {
          if (node.nodeType === 1) this.#teardownTree(node);
        });
      }
    });
    this.observer.observe(this.element, {childList: true, subtree: true});
  }

  disconnect() {
    this.observer?.disconnect();
    this.element.querySelectorAll("[data-datepicker-ready]").forEach((input) => {
      this.#destroy(input);
    });
  }

  #upgradeTree(root) {
    if (root instanceof HTMLInputElement) this.#upgrade(root);
    root.querySelectorAll?.("input").forEach((input) => this.#upgrade(input));
  }

  #teardownTree(root) {
    const inputs = [];
    if (root.matches?.("[data-datepicker-ready]")) inputs.push(root);
    root.querySelectorAll?.("[data-datepicker-ready]").forEach((input) => inputs.push(input));
    inputs.forEach((input) => {
      if (input.isConnected) return;
      this.#destroy(input);
    });
  }

  #destroy(input) {
    const picker = input.datepicker;
    if (!picker) return;

    // Turbo may have already dropped the old document body, picker included.
    if (!picker.picker?.element?.isConnected) {
      delete input.datepicker;
      return;
    }

    picker.destroy();
  }

  #upgrade(input) {
    if (!(input instanceof HTMLInputElement)) return;
    if (input.dataset.datepickerSkip != null) return;

    if (input.dataset.datepickerReady === "true") {
      this.#bind(input);
      if (!input.disabled && !input.datepicker) this.#attach(input);
      return;
    }

    if (input.type !== "date") return;

    const parsed = parseIsoDate(input.value);
    const iso = parsed ? formatIsoDate(parsed) : "";

    input.dataset.datepickerReady = "true";
    input.dataset.isoDate = iso;
    input.type = "text";
    input.value = parsed ? formatDisplayDate(parsed) : "";
    input.placeholder = input.placeholder || "dd/mm/aaaa";
    input.autocomplete = "off";
    input.classList.remove("p-2.5");
    input.classList.add(
      "py-2.5",
      "pe-2.5",
      "ps-10",
      "placeholder:text-body-subtle",
      "disabled:cursor-not-allowed",
      "disabled:opacity-60"
    );

    this.#wrap(input);

    if (input.name && !input.disabled) {
      const hidden = document.createElement("input");
      hidden.type = "hidden";
      hidden.name = input.name;
      hidden.value = iso;
      hidden.dataset.datepickerValue = "true";
      input.removeAttribute("name");
      input.after(hidden);
    }

    this.#bind(input);
    if (!input.disabled) this.#attach(input);
  }

  #bind(input) {
    if (this.bound.has(input)) return;

    this.bound.add(input);
    input.addEventListener("changeDate", () => this.#sync(input));
    input.addEventListener("show", () => this.#fit(input));
  }

  #wrap(input) {
    if (input.parentElement?.dataset.datepickerWrapper != null) return;

    const wrapper = document.createElement("div");
    wrapper.className = "relative min-w-0 w-full flex-1";
    wrapper.dataset.datepickerWrapper = "true";
    input.before(wrapper);
    wrapper.appendChild(input);

    const icon = document.createElement("div");
    icon.className = "pointer-events-none absolute inset-y-0 start-0 flex items-center ps-3.5";
    icon.innerHTML = `<i class="fa-solid fa-calendar text-body" aria-hidden="true"></i>`;
    wrapper.prepend(icon);
  }

  #attach(input) {
    if (input.disabled || input.datepicker) return;

    const options = {
      autohide: true,
      format: "dd/mm/yyyy",
      language: "es",
      todayBtn: true,
      clearBtn: true,
      todayBtnMode: 1,
      todayHighlight: true,
      container: "body",
      orientation: "auto"
    };
    const min = parseIsoDate(input.getAttribute("min"));
    const max = parseIsoDate(input.getAttribute("max"));
    if (min) options.minDate = min;
    if (max) options.maxDate = max;

    new Datepicker(input, options);
    this.#sync(input);
  }

  #sync(input) {
    const date = input.datepicker?.getDate();
    const hidden = input.nextElementSibling?.dataset.datepickerValue === "true"
      ? input.nextElementSibling
      : null;

    if (!(date instanceof Date) || Number.isNaN(date.getTime())) {
      if (input.value.trim() === "") {
        input.dataset.isoDate = "";
        if (hidden) hidden.value = "";
      }
      return;
    }

    const iso = formatIsoDate(date);
    input.dataset.isoDate = iso;
    if (hidden) hidden.value = iso;
  }

  // The library only flips upward when the whole popup fits above the field.
  // In a modal that leaves the action buttons below the viewport, so pull the
  // popup back inside the window.
  #fit(input) {
    const picker = input.datepicker?.picker?.element;
    if (!picker) return;

    const margin = 8;
    const rect = picker.getBoundingClientRect();
    let shift = 0;

    if (rect.bottom > window.innerHeight - margin) {
      shift = window.innerHeight - margin - rect.bottom;
    }
    if (rect.top + shift < margin) {
      shift = margin - rect.top;
    }
    if (shift === 0) return;

    const current = parseFloat(picker.style.top) || 0;
    picker.style.top = `${current + shift}px`;
  }
}
