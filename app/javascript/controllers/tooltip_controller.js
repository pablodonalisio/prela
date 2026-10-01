import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tooltip"
//
// Flowbite positions an element that must already exist in the DOM, so the
// bubble is built here and appended to <body> to escape overflow clipping.
export default class extends Controller {
  static values = {
    text: String,
    placement: { type: String, default: "top" }
  };

  connect() {
    const Tooltip = window.Flowbite?.Tooltip ?? window.Tooltip;
    if (!Tooltip || this.textValue.length === 0) return;

    this.bubble = document.createElement("div");
    this.bubble.setAttribute("role", "tooltip");
    this.bubble.className =
      "tooltip absolute z-50 invisible inline-block max-w-xs rounded-lg bg-gray-900 px-3 py-2 text-sm font-medium text-white opacity-0 shadow-sm transition-opacity duration-300 dark:bg-gray-700";
    this.bubble.textContent = this.textValue;

    const arrow = document.createElement("div");
    arrow.className = "tooltip-arrow";
    arrow.setAttribute("data-popper-arrow", "");
    this.bubble.appendChild(arrow);

    document.body.appendChild(this.bubble);

    this.tooltip = new Tooltip(this.bubble, this.element, {
      placement: this.placementValue,
      triggerType: "hover"
    });
  }

  disconnect() {
    this.tooltip?.destroyAndRemoveInstance();
    this.tooltip = null;
    this.bubble?.remove();
    this.bubble = null;
  }
}
