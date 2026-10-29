import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "panel"];

  show(event) {
    const index = this.tabTargets.indexOf(event.currentTarget);

    this.panelTargets.forEach((panel, panelIndex) => {
      panel.classList.toggle("hidden", panelIndex !== index);
    });

    this.tabTargets.forEach((tab, tabIndex) => {
      tab.setAttribute("aria-selected", tabIndex === index);
    });
  }
}
