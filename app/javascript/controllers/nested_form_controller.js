import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];

  add(event) {
    event.preventDefault();
    if (!this.hasTemplateTarget || !this.hasContainerTarget) return;

    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now().toString());
    this.containerTarget.insertAdjacentHTML("beforeend", html);
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest("[data-nested-form-target='item']");
    if (!row) return;

    const destroyInput = row.querySelector("input[name*='[_destroy]']");
    if (destroyInput) {
      destroyInput.value = "1";
      row.classList.add("d-none");
      return;
    }

    row.remove();
  }
}
