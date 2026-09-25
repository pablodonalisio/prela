import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["existingFile", "input", "newFile"];

  connect() {}

  changeFile() {
    this.#setHidden(this.existingFileTarget, true);
    this.existingFileTarget.getElementsByTagName("input")[0].disabled = true;
    this.#setHidden(this.newFileTarget, false);
    this.inputTarget.disabled = false;
  }

  reloadExistingFile() {
    this.#setHidden(this.existingFileTarget, false);
    this.existingFileTarget.getElementsByTagName("input")[0].disabled = false;
    this.#setHidden(this.newFileTarget, true);
    this.inputTarget.disabled = true;
  }

  #setHidden(element, hidden) {
    element.classList.toggle("hidden", hidden);
  }
}
