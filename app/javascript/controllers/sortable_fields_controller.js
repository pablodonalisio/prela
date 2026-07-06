import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "item"];

  connect() {
    this.draggedItem = null;
    this.updatePositions();
    this.observer = new MutationObserver(() => this.updatePositions());
    this.observer.observe(this.listTarget, { childList: true });
  }

  disconnect() {
    this.observer?.disconnect();
  }

  dragStart(event) {
    this.draggedItem = event.target.closest("[data-sortable-fields-target='item']");
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", "");
    this.draggedItem?.classList.add("opacity-50");
  }

  dragOver(event) {
    event.preventDefault();
    if (!this.draggedItem) return;

    const item = event.target.closest("[data-sortable-fields-target='item']");
    if (!item || item === this.draggedItem) return;

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
    this.updatePositions();
  }

  updatePositions() {
    this.itemTargets.forEach((item, index) => {
      const input = item.querySelector("[data-sortable-fields-position]");
      if (input) input.value = index;
    });
  }
}
