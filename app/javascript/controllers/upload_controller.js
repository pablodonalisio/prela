import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["existingImage", "input", "newImage"];

  connect() {}

  changeImage() {
    this.existingImageTarget.classList.add("d-none");
    this.existingImageTarget.getElementsByTagName("input")[0].disabled = true;
    this.newImageTarget.classList.remove("d-none");
    this.inputTarget.disabled = false;
  }

  reloadExistingImage() {
    this.existingImageTarget.classList.remove("d-none");
    this.existingImageTarget.getElementsByTagName("input")[0].disabled = false;
    this.newImageTarget.classList.add("d-none");
    this.inputTarget.disabled = true;
  }
}
