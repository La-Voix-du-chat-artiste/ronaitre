import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "showLabel", "hideLabel"]

  toggle(event) {
    const visible = event.target.checked
    this.inputTarget.type = visible ? "text" : "password"
    this.showLabelTarget.classList.toggle("hidden", visible)
    this.hideLabelTarget.classList.toggle("hidden", !visible)
  }
}
