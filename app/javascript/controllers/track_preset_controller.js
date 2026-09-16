import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip", "presetId", "colorField", "name"]

  connect() {
    this.select(this.chipTargets[0])
  }

  select(event) {
    const chip = event.currentTarget || event
    this.chipTargets.forEach((el) => el.dataset.selected = (el === chip).toString())

    const slug = chip.dataset.trackPresetSlugValue
    this.presetIdTarget.value = slug === "custom" ? "" : chip.dataset.trackPresetIdValue

    if (this.hasColorFieldTarget) {
      this.colorFieldTarget.classList.toggle("hidden", slug !== "custom")
    }

    if (slug !== "custom" && chip.dataset.trackPresetNameValue) {
      const nameInput = document.getElementById("track_name")
      if (nameInput && (nameInput.value === "" || nameInput.dataset.autofilled === "true")) {
        nameInput.value = chip.dataset.trackPresetNameValue
        nameInput.dataset.autofilled = "true"
      }
    }
  }
}
