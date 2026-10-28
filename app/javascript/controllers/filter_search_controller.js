import { Controller } from "@hotwired/stimulus"

// Submits the closest filter form shortly after the user stops typing.
export default class extends Controller {
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), 300)
  }

  cancel() {
    clearTimeout(this.timeout)
  }

  disconnect() {
    this.cancel()
  }
}
