import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dismiss"
//
// Flowbite's own Dismiss component binds data-dismiss-target on turbo:load
// only. Flash messages are re-rendered through turbo streams, so their buttons
// would never get wired up; a Stimulus action is bound automatically instead.
export default class extends Controller {
  close() {
    this.element.remove();
  }
}
