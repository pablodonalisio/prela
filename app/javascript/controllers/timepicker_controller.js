import { Controller } from "@hotwired/stimulus";
import {
  SELECT_LIST_CLASSES,
  SELECT_MENU_CLASSES,
  SELECT_OPTION_CLASSES,
  SELECT_OPTION_SELECTED_CLASS
} from "select_menu_styles";

const INTERVAL_MINUTES = 30;

// Flowbite timepicker: a clock-prefixed field whose menu lists the day in
// 30-minute steps. Typing follows an HH:MM mask. The menu is portaled to
// body so the modal's overflow does not clip it, same as the datepicker popup.
export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.previousValue = maskTime(this.inputTarget.value);
    if (this.inputTarget.value !== this.previousValue) {
      this.inputTarget.value = this.previousValue;
    }
    this.#buildMenu();
    this.#highlight();
    this.#initDropdown();
  }

  disconnect() {
    this.dropdown?.destroyAndRemoveInstance?.();
    this.dropdown = null;
    this.menu?.remove();
    this.menu = null;
  }

  open() {
    this.#syncWidth();
    requestAnimationFrame(() => this.#scrollSelected());
  }

  guardKey(event) {
    if (event.ctrlKey || event.metaKey || event.altKey) return;
    if (event.key.length !== 1) return;
    if (/^\d$/.test(event.key)) return;

    event.preventDefault();
  }

  mask() {
    const input = this.inputTarget;
    const deleting = input.value.length < this.previousValue.length;
    const formatted = maskTime(input.value, {deleting});
    this.#setValue(formatted);
  }

  normalize() {
    const normalized = normalizeTypedTime(this.inputTarget.value);
    if (normalized) this.#setValue(normalized);
    this.#highlight();
  }

  #buildMenu() {
    this.menu = document.createElement("div");
    this.menu.id = `timepicker-${crypto.randomUUID()}`;
    this.menu.className = `${SELECT_MENU_CLASSES} !z-[70]`;
    this.menu.setAttribute("role", "listbox");

    const list = document.createElement("ul");
    list.className = SELECT_LIST_CLASSES;

    for (let minutes = 0; minutes < 24 * 60; minutes += INTERVAL_MINUTES) {
      const value = formatMinutes(minutes);
      const item = document.createElement("li");
      const option = document.createElement("button");
      option.type = "button";
      option.className = SELECT_OPTION_CLASSES;
      option.textContent = value;
      option.dataset.value = value;
      option.setAttribute("role", "option");
      option.addEventListener("click", () => this.#choose(value));
      item.appendChild(option);
      list.appendChild(item);
    }

    this.menu.appendChild(list);
    document.body.appendChild(this.menu);
  }

  #initDropdown() {
    const Dropdown = window.Flowbite?.Dropdown ?? window.Flowbite?.default?.Dropdown ?? window.Dropdown;
    if (!Dropdown) return;

    this.dropdown = new Dropdown(this.menu, this.inputTarget, {
      placement: "bottom-start",
      triggerType: "click",
      offsetDistance: 8,
      onShow: () => {
        this.#syncWidth();
        this.#scrollSelected();
      }
    });
  }

  #choose(value) {
    this.#setValue(value);
    this.inputTarget.dispatchEvent(new Event("input", {bubbles: true}));
    this.inputTarget.dispatchEvent(new Event("change", {bubbles: true}));
    this.dropdown?.hide();
  }

  #setValue(value) {
    const input = this.inputTarget;
    this.previousValue = value;
    if (input.value !== value) input.value = value;
    if (document.activeElement === input) input.setSelectionRange(value.length, value.length);
    this.#highlight();
  }

  #highlight() {
    const value = this.inputTarget.value;
    this.menu.querySelectorAll("button").forEach((option) => {
      const selected = option.dataset.value === value;
      option.classList.toggle(SELECT_OPTION_SELECTED_CLASS, selected);
      option.setAttribute("aria-selected", selected ? "true" : "false");
    });
  }

  #scrollSelected() {
    const selected = this.menu.querySelector(`[data-value="${CSS.escape(this.inputTarget.value)}"]`);
    selected?.scrollIntoView({block: "nearest"});
  }

  #syncWidth() {
    this.menu.style.width = `${this.inputTarget.offsetWidth}px`;
  }
}

function maskTime(raw, {deleting = false} = {}) {
  let hours = "";
  let minutes = "";

  for (const char of (raw || "").replace(/\D/g, "")) {
    const digit = Number(char);

    if (hours.length === 0) {
      hours = digit > 2 ? `0${char}` : char;
    } else if (hours.length === 1) {
      if (hours === "2" && digit > 3) continue;
      hours += char;
    } else if (minutes.length === 0) {
      if (digit > 5) continue;
      minutes += char;
    } else if (minutes.length === 1) {
      minutes += char;
    }
  }

  if (hours.length < 2) return hours;
  if (!minutes.length) return deleting ? hours : `${hours}:`;
  return `${hours}:${minutes}`;
}

function normalizeTypedTime(value) {
  const match = /^(\d{1,2}):(\d{2})$/.exec((value || "").trim());
  if (!match) return "";

  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  if (hours > 23 || minutes > 59) return "";

  return `${String(hours).padStart(2, "0")}:${match[2]}`;
}

function formatMinutes(total) {
  const hours = String(Math.floor(total / 60)).padStart(2, "0");
  const minutes = String(total % 60).padStart(2, "0");
  return `${hours}:${minutes}`;
}
