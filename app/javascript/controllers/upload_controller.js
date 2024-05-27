import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["existingFile", "input", "newFile"];

  connect() {}

  changeFile() {
    this.existingFileTarget.classList.add("d-none");
    this.existingFileTarget.getElementsByTagName("input")[0].disabled = true;
    this.newFileTarget.classList.remove("d-none");
    this.inputTarget.disabled = false;
  }

  reloadExistingFile() {
    this.existingFileTarget.classList.remove("d-none");
    this.existingFileTarget.getElementsByTagName("input")[0].disabled = false;
    this.newFileTarget.classList.add("d-none");
    this.inputTarget.disabled = true;
  }
}
