import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "observationsTemplate", "imagesTemplate"];

  connect() {
    this.draggedItem = null;
    this.reindex();
  }

  dragStart(event) {
    this.draggedItem = event.target.closest("[data-sortable-sections-target='item']");
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", "");
    this.draggedItem?.classList.add("opacity-50");
  }

  dragOver(event) {
    if (!this.draggedItem) return;

    event.preventDefault();
    const item = event.target.closest("[data-sortable-sections-target='item']");
    if (!item || item === this.draggedItem || !this.listTarget.contains(item)) return;

    const after = event.clientY > item.getBoundingClientRect().top + item.offsetHeight / 2;
    if (after) {
      item.after(this.draggedItem);
    } else {
      item.before(this.draggedItem);
    }
  }

  dragEnd() {
    this.draggedItem?.classList.remove("opacity-50");
    this.draggedItem = null;
    this.reindex();
  }

  add(event) {
    const template = event.params.kind === "images" ? this.imagesTemplateTarget : this.observationsTemplateTarget;
    const html = template.innerHTML.replaceAll("NEW_ID", this.newId());
    this.listTarget.insertAdjacentHTML("beforeend", html);
    this.reindex();
    const items = this.listTarget.querySelectorAll("[data-sortable-sections-target='item']");
    items[items.length - 1]?.querySelector("[data-section-title]")?.focus();
  }

  remove(event) {
    if (event.params.confirm && !window.confirm(event.params.confirm)) return;

    event.target.closest("[data-sortable-sections-target='item']")?.remove();
    this.reindex();
  }

  reindex() {
    this.listTarget.querySelectorAll("[data-sortable-sections-target='item']").forEach((item, index) => {
      item.querySelectorAll("[name^='report_template[layout]']").forEach((input) => {
        input.name = input.name.replace(
          /report_template\[layout\]\[[^\]]+\]/,
          `report_template[layout][${index}]`,
        );
      });
    });
  }

  newId() {
    if (window.crypto?.randomUUID) return window.crypto.randomUUID();

    return `block-${Date.now()}-${Math.random().toString(16).slice(2)}`;
  }
}
