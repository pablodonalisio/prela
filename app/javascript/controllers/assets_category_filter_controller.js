import { Controller } from "@hotwired/stimulus"

// After a turbo stream re-renders the filter, drop categories that no longer
// exist from the address bar so a reload matches the dropdown.
export default class extends Controller {
  connect() {
    const url = new URL(window.location.href)
    const current = url.searchParams.getAll("assets_category_ids[]").sort()
    const selected = Array.from(this.element.querySelectorAll("input[name='assets_category_ids[]']:checked"))
      .map((input) => input.value)
      .sort()

    if (current.join() === selected.join()) return

    url.searchParams.delete("assets_category_ids[]")
    selected.forEach((id) => url.searchParams.append("assets_category_ids[]", id))
    history.replaceState(history.state, "", url)
  }
}
