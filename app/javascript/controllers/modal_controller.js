import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
//
// The modal shell lives in the layout and Turbo loads content into the frame
// inside it. Flowbite is driven programmatically rather than through
// data-modal-* attributes: those are only wired up on turbo:load, so they
// would miss content injected later by the frame.
export default class extends Controller {
  connect() {
    const Modal = window.Flowbite?.Modal ?? window.Flowbite?.default?.Modal ?? window.Modal;
    if (!Modal) return;

    this.modal = new Modal(this.element, {
      placement: "center",
      backdrop: "dynamic",
      closable: true
    });

    // turbo:frame-load does not bubble, and Turbo replaces the frame node so a
    // listener on the original element is lost. Capture on the shell instead.
    this.onFrameLoad = this.open.bind(this);
    this.element.addEventListener("turbo:frame-load", this.onFrameLoad, true);
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.onFrameLoad, true);

    // Leaves no orphan backdrop or overflow-hidden on <body> behind when Turbo
    // swaps the page out while the modal is open.
    this.modal?.hide();
    this.modal?.destroyAndRemoveInstance();
    this.modal = null;
  }

  open() {
    const frame = this.element.querySelector("#remote_modal");
    if (!frame || frame.innerHTML.trim() === "") return;

    // Frame load re-inits Flowbite dropdowns and drops the open menu without
    // adding `hidden`, so close every instance once the dialog is up.
    this._hideDropdowns();
    this.modal?.show();
  }

  _hideDropdowns() {
    const dropdowns = window.FlowbiteInstances?.getInstances?.("Dropdown");
    if (!dropdowns) return;

    Object.values(dropdowns).forEach((dropdown) => dropdown?.hide?.());
  }

  dismiss() {
    this.modal?.hide();
  }

  close(event) {
    const keepModalOpen =
      event.detail?.formSubmission?.submitter?.dataset?.keepModalOpen;

    if (event.detail?.success && !keepModalOpen) {
      this.modal?.hide();
    }
  }
}
