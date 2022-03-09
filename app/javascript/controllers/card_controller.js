import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["delete"]
  connect() {
    console.log("hello from card_controller!")
  }
  hoverDelete() {
    console.log(this.deleteTarget.classList)
    this.deleteTarget.classList.toggle("hover")
  }
}
