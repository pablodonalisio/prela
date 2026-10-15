import { Controller } from "@hotwired/stimulus";

// Turbo streams cannot run scripts. This node is appended by the stream and
// calls the browser alert once, then removes itself.
export default class extends Controller {
  static values = {message: String};

  connect() {
    if (this.messageValue) window.alert(this.messageValue);
    this.element.remove();
  }
}
