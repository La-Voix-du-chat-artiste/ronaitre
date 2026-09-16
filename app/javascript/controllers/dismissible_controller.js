import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }

  connect() {
    if (localStorage.getItem(this.storageKey) === "1") this.element.remove()
  }

  dismiss() {
    localStorage.setItem(this.storageKey, "1")
    this.element.remove()
  }

  get storageKey() {
    return `ronaitre-dismissed-${this.keyValue}`
  }
}
