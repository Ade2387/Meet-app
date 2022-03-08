import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]
  connect() {
    console.log("hello from sidebar_controller!")
  }
  active() {
    console.log(this.listTarget.classList)
    this.listTargets.forEach(element => {

      element.classList.add("active")
    })
  }
}
