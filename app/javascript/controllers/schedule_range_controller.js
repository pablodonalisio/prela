import { Controller } from "@hotwired/stimulus"
import { parseIsoDate } from "controllers/date_format"

// Keeps the finish picker from accepting a datetime earlier than the start.
export default class extends Controller {
  static targets = ["init", "finish"]

  connect() {
    this.syncFinishMin()
  }

  syncFinishMin() {
    if (!this.hasInitTarget || !this.hasFinishTarget || this.clearing) return

    const start = this.#output(this.initTarget)
    const startDay = start ? start.slice(0, 10) : (this.#dateInput(this.initTarget).getAttribute("min") || "")
    this.#setMin(this.#dateInput(this.finishTarget), startDay)

    const finish = this.#output(this.finishTarget)
    if (!start || !finish) return

    const timeBlank = this.#timeInput(this.finishTarget).value.trim() === ""
    if (finish.slice(0, 10) < start.slice(0, 10) || (!timeBlank && finish <= start)) {
      this.#clear(this.finishTarget)
    }
  }

  #output(wrapper) {
    return wrapper.querySelector("[data-datetime-field-target='output']")?.value || ""
  }

  #dateInput(wrapper) {
    return wrapper.querySelector("[data-datetime-field-target='date']")
  }

  #timeInput(wrapper) {
    return wrapper.querySelector("[data-datetime-field-target='time']")
  }

  #setMin(input, isoDay) {
    if (!input) return

    input.min = isoDay
    const minDate = parseIsoDate(isoDay)
    if (minDate && input.datepicker) input.datepicker.setOptions({ minDate })
  }

  #clear(wrapper) {
    this.clearing = true
    this.#timeInput(wrapper).value = ""

    const dateInput = this.#dateInput(wrapper)
    const output = wrapper.querySelector("[data-datetime-field-target='output']")
    if (dateInput.datepicker?.getDate()) {
      dateInput.datepicker.setDate({ clear: true })
    } else {
      dateInput.value = ""
      delete dateInput.dataset.isoDate
      if (output) output.value = ""
    }

    this.clearing = false
  }
}
