import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme"
//
// Dark is the default. The chosen theme is persisted so it survives reloads,
// and the layout applies it inline before first paint to avoid a flash of the
// wrong theme; this controller only handles toggling afterwards.
export default class extends Controller {
  static targets = ["darkIcon", "lightIcon"];
  static STORAGE_KEY = "prela:theme";

  connect() {
    this.#syncIcons();
  }

  toggle() {
    const isDark = document.documentElement.classList.toggle("dark");
    localStorage.setItem(
      this.constructor.STORAGE_KEY,
      isDark ? "dark" : "light"
    );
    this.#syncIcons();
  }

  #syncIcons() {
    const isDark = document.documentElement.classList.contains("dark");

    if (this.hasDarkIconTarget) this.darkIconTarget.classList.toggle("hidden", isDark);
    if (this.hasLightIconTarget) this.lightIconTarget.classList.toggle("hidden", !isDark);
  }
}
