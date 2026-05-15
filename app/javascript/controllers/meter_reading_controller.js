import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["startDate", "endDate", "opening", "closing", "consumption"]

    connect() {
        this.timeout = null
    }

    update() {
        this.updateConsumption()
        this.saveReading()
    }

    updateConsumption() {
        const opening = parseFloat(this.openingTarget.value)
        const closing = parseFloat(this.closingTarget.value)

        if (Number.isNaN(opening) || Number.isNaN(closing)) {
            this.consumptionTarget.textContent = "-"
            return
        }

        const consumption = closing - opening
        const unit = this.consumptionTarget.dataset.unit

        this.consumptionTarget.textContent = `${Math.round(consumption)} ${unit}`
    }

    saveReading() {
        clearTimeout(this.timeout)

        this.timeout = setTimeout(() => {
            const csrfToken = document.querySelector("meta[name='csrf-token']").content

            fetch(this.consumptionTarget.dataset.updateUrl, {
                method: "PATCH",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "text/vnd.turbo-stream.html",
                    "X-CSRF-Token": csrfToken
                },
                body: JSON.stringify({
                    meter_reading: {
                        start_date: this.startDateTarget.value,
                        end_date: this.endDateTarget.value,
                        opening_reading: this.openingTarget.value,
                        closing_reading: this.closingTarget.value
                    }
                })
            })
                .then(response => response.text())
                .then(html => {
                    Turbo.renderStreamMessage(html)
                })
        }, 600)
    }
}