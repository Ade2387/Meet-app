import { Controller } from "stimulus"
import flatpickr from "flatpickr"
// import rangePlugin from "flatpickr/dist/plugins/rangePlugin"

export default class extends Controller {
  static targets = [ "end", "start" ]

  connect() {
    console.log("Date-Controller connected")

    flatpickr(this.endTarget, {
      altInput: true,
      minDate: "today",
      enableTime: true,
      // "plugins": [new rangePlugin({ input: "#range_end"})]
    })
    flatpickr(this.startTarget, {
      altInput: true,
      minDate: "today",
      enableTime: true,
      // "plugins": [new rangePlugin({ input: "#range_end"})]
    })
  }
}
