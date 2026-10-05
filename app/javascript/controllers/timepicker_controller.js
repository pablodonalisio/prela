import { Controller } from "@hotwired/stimulus";

// Wraps native time inputs with Flowbite's timepicker layout: a clock icon
// on the start edge so they line up with the datepicker in the same row.
export default class extends Controller {
  connect() {
    this.#upgradeTree(this.element);
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1) this.#upgradeTree(node);
        });
      }
    });
    this.observer.observe(this.element, {childList: true, subtree: true});
  }

  disconnect() {
    this.observer?.disconnect();
  }

  #upgradeTree(root) {
    if (root instanceof HTMLInputElement) this.#upgrade(root);
    root.querySelectorAll?.("input[type='time']").forEach((input) => this.#upgrade(input));
  }

  #upgrade(input) {
    if (!(input instanceof HTMLInputElement)) return;
    if (input.type !== "time") return;
    if (input.dataset.timepickerSkip != null) return;
    if (input.dataset.timepickerReady === "true") return;

    input.dataset.timepickerReady = "true";
    input.classList.remove("p-2.5");
    input.classList.add(
      "leading-none",
      "py-2.5",
      "pe-2.5",
      "ps-10",
      "placeholder:text-body-subtle",
      "disabled:cursor-not-allowed",
      "disabled:opacity-60"
    );
    this.#wrap(input);
  }

  #wrap(input) {
    if (input.parentElement?.dataset.timepickerWrapper != null) return;

    const wrapper = document.createElement("div");
    wrapper.className = "relative min-w-0 w-full flex-1";
    wrapper.dataset.timepickerWrapper = "true";
    input.before(wrapper);
    wrapper.appendChild(input);

    const icon = document.createElement("div");
    icon.className = "pointer-events-none absolute inset-y-0 start-0 flex items-center ps-3.5";
    icon.innerHTML = `<i class="fa-solid fa-clock text-body" aria-hidden="true"></i>`;
    wrapper.prepend(icon);
  }
}
