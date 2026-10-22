import { Controller } from "@hotwired/stimulus";

// Clones a <template> blueprint into the container. Nested blueprints (a list
// inside a section) must be cloned as DOM, not reparsed from innerHTML:
// reparsing drops the inner template content and leaves the placeholder index
// in the submitted fields, which Rails then rejects.
export default class extends Controller {
  static targets = ["container", "template"];
  static values = {placeholder: {type: String, default: "NEW_RECORD"}};

  add(event) {
    event.preventDefault();
    if (!this.owns(event)) return;
    if (!this.hasTemplateTarget || !this.hasContainerTarget) return;

    const fragment = this.templateTarget.content.cloneNode(true);
    this.replacePlaceholder(fragment, this.placeholderValue, Date.now().toString());
    this.containerTarget.append(fragment);
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

  owns(event) {
    const source = event.target instanceof Element ? event.target : event.target?.parentElement;
    return source?.closest("[data-controller~='nested-form']") === this.element;
  }

  replacePlaceholder(root, placeholder, value) {
    root.querySelectorAll("*").forEach((element) => {
      for (const attr of [...element.attributes]) {
        if (!attr.value.includes(placeholder)) continue;

        element.setAttribute(attr.name, attr.value.split(placeholder).join(value));
      }

      if (element instanceof HTMLTemplateElement) {
        this.replacePlaceholder(element.content, placeholder, value);
      }
    });
  }
}
