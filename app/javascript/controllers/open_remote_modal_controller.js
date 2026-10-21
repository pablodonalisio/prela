import { Controller } from "@hotwired/stimulus";

// A full-page visit can land on a tab and only then open the shared modal.
// The frame lives in the layout, so this waits until that shell is connected
// and loads the form into it.
export default class extends Controller {
  static values = { url: String };

  connect() {
    if (document.documentElement.hasAttribute("data-turbo-preview")) return;

    this.opened = false;
    this.open = this.open.bind(this);
    requestAnimationFrame(this.open);
  }

  disconnect() {
    this.opened = true;
  }

  open() {
    if (this.opened || !this.hasUrlValue) return;

    const frame = document.getElementById("remote_modal");
    if (!frame) return;

    this.opened = true;
    frame.src = this.urlValue;
    this.element.remove();
    this.#clearOpenParam();
  }

  #clearOpenParam() {
    const url = new URL(window.location.href);
    if (!url.searchParams.has("open")) return;

    url.searchParams.delete("open");
    window.history.replaceState(window.history.state, "", url);
  }
}
