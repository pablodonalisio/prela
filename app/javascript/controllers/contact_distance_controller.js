import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reportsTo", "distanceAbove"]

  syncDistance() {
    if (!this.hasReportsToTarget || !this.hasDistanceAboveTarget) return

    const hasSuperior = this.reportsToTarget.value !== ""
    const current = Number.parseInt(this.distanceAboveTarget.value, 10)

    if (hasSuperior && (Number.isNaN(current) || current < 1)) {
      this.distanceAboveTarget.value = "1"
    }
  }
}
