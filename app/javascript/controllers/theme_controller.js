import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme"
//
// Dark is the default. The chosen theme is persisted so it survives reloads,
// and the layout applies it inline before first paint to avoid a flash of the
// wrong theme; this controller only handles toggling afterwards.
// The moon is shown while dark is active, the sun while light is active.
export default class extends Controller {
  static targets = ["darkIcon", "lightIcon"];
  static STORAGE_KEY = "prela:theme";
  static TRANSITION_MS = 400;

  connect() {
    this.#syncIcons();
  }

  toggle() {
    this.#withColorTransition(() => {
      const isDark = document.documentElement.classList.toggle("dark");
      localStorage.setItem(
        this.constructor.STORAGE_KEY,
        isDark ? "dark" : "light"
      );
      this.#syncIcons();
    });
  }

  #withColorTransition(apply) {
    const root = document.documentElement;

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      apply();
      return;
    }

    root.classList.add("theme-transitioning");
    // Force a reflow so the transition is in place before colors change.
    void root.offsetWidth;
    apply();

    clearTimeout(this.transitionTimeout);
    this.transitionTimeout = window.setTimeout(() => {
      root.classList.remove("theme-transitioning");
      this.transitionTimeout = null;
    }, this.constructor.TRANSITION_MS);
  }

  #syncIcons() {
    const isDark = document.documentElement.classList.contains("dark");

    if (this.hasDarkIconTarget) this.darkIconTarget.classList.toggle("hidden", !isDark);
    if (this.hasLightIconTarget) this.lightIconTarget.classList.toggle("hidden", isDark);
  }
}
