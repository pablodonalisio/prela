import { Controller } from "@hotwired/stimulus";

// Flowbite closes a dropdown only on an outside click. An item that loads the
// remote modal never leaves the page, and the turbo:frame-load reinit replaces
// the Dropdown instance without hiding the menu, so it stays open over the dialog.
export default class extends Controller {
  static targets = ["menu"];

  hide() {
    const menu = this.menuTarget;
    const instances = window.FlowbiteInstances;
    const id = menu.id;

    if (id && typeof instances?.instanceExists === "function" && instances.instanceExists("Dropdown", id)) {
      instances.getInstance("Dropdown", id)?.hide();
      return;
    }

    menu.classList.remove("block");
    menu.classList.add("hidden");
  }
}
