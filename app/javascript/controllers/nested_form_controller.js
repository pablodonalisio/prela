import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];
  static values = {placeholder: {type: String, default: "NEW_RECORD"}};

  add(event) {
    event.preventDefault();
    if (!this.hasTemplateTarget || !this.hasContainerTarget) return;

    const html = this.templateTarget.innerHTML.split(this.placeholderValue).join(Date.now().toString());
    this.containerTarget.insertAdjacentHTML("beforeend", html);
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest("[data-nested-form-target='item']");
    if (!row) return;

    const destroyInput = row.querySelector("input[name*='[_destroy]']");
    if (destroyInput) {
      destroyInput.value = "1";
      row.classList.add("hidden");
      return;
    }

    row.remove();
  }
}
