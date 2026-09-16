import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "time", "months", "daysUnit"]
  static values = { elapsed: Number }

  connect() {
    this.render()
    if (this.reducedMotion()) return
    this.timer = setInterval(() => {
      this.elapsedValue += 1
      this.render()
    }, 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  render() {
    const total = Math.max(0, this.elapsedValue)
    const days = Math.floor(total / 86400)
    const rest = total % 86400
    const hours = String(Math.floor(rest / 3600)).padStart(2, "0")
    const minutes = String(Math.floor((rest % 3600) / 60)).padStart(2, "0")
    const seconds = String(rest % 60).padStart(2, "0")

    this.daysTarget.textContent = days.toLocaleString("fr-FR")
    this.timeTarget.textContent = `${hours}:${minutes}:${seconds}`

    if (this.hasMonthsTarget) {
      this.monthsTarget.textContent = Math.floor(days / 30).toLocaleString("fr-FR")
    }
    if (this.hasDaysUnitTarget) {
      this.daysUnitTarget.textContent = this.pluralizeDays(days)
    }
  }

  pluralizeDays(days) {
    if (window.I18nDaysUnit) return window.I18nDaysUnit(days)
    return days > 1 ? "jours" : "jour"
  }

  reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
