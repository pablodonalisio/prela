import { Controller } from "@hotwired/stimulus";

// Pagination links live under the list and update the surrounding Turbo frame.
// The viewport would otherwise stay at the bottom, so after the new page
// arrives we scroll the list itself into view.
export default class extends Controller {
  static targets = ["list"];

  scroll(event) {
    const link = event.target.closest("a");
    if (!link || !this.element.contains(link) || !this.hasListTarget) return;
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0) return;

    const listId = this.listTarget.id;
    const frame = link.dataset.turboFrame === "_top" ? null : this.element.closest("turbo-frame");

    const scrollToList = () => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          document.getElementById(listId)?.scrollIntoView({ behavior: "smooth", block: "start" });
        });
      });
    };

    if (frame) {
      const onFrameLoad = (loadEvent) => {
        if (loadEvent.target !== frame) return;

        frame.removeEventListener("turbo:frame-load", onFrameLoad);
        scrollToList();
      };

      frame.addEventListener("turbo:frame-load", onFrameLoad);
    } else {
      document.addEventListener("turbo:load", scrollToList, { once: true });
    }
  }
}
