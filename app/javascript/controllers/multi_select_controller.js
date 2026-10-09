import { Controller } from "@hotwired/stimulus"

// Dropdown that keeps a set of checkboxes as the real form fields.
// Choosing an option submits the closest form so the list can refresh
// without closing the menu.
export default class extends Controller {
  static targets = ["menu", "button", "label", "option"]
  static values = { placeholder: { type: String, default: "Todos" } }

  connect() {
    this._onDocumentClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    document.addEventListener("click", this._onDocumentClick)
    this._syncLabel()
  }

  disconnect() {
    document.removeEventListener("click", this._onDocumentClick)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this._open()
    } else {
      this.close()
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  changed() {
    this._syncLabel()
    this.element.closest("form")?.requestSubmit()
  }

  _open() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  _syncLabel() {
    const selected = this.optionTargets
      .filter((option) => option.checked)
      .map((option) => option.dataset.label)

    this.labelTarget.textContent = selected.length ? selected.join(", ") : this.placeholderValue
  }
}
