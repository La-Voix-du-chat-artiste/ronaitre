import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bubble"]
  static values = { sender: String }

  connect() {
    const currentUserId = document.body.dataset.currentUserId
    if (currentUserId && String(currentUserId) === this.senderValue) {
      this.element.classList.add("justify-end")
      this.bubbleTarget.classList.remove("bg-muted", "text-foreground")
      this.bubbleTarget.classList.add("bg-primary", "text-primary-foreground")
    }
  }
}
