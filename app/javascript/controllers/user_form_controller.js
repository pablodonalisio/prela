import { Controller } from "@hotwired/stimulus";

// Editor and client only apply to client users. Hide those fields for every
// other role, and keep them in sync when the role select changes.
export default class extends Controller {
  static targets = ["role", "clientFields"];

  connect() {
    this.toggleClientFields();
  }

  toggleClientFields() {
    if (!this.hasRoleTarget || !this.hasClientFieldsTarget) return;

    this.clientFieldsTarget.classList.toggle("hidden", this.roleTarget.value !== "client");
  }
}
