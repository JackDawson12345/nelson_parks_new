// app/javascript/controllers/invoice_batch_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["park", "utility"]

    connect() {
        this.toggleUtilityOptions()
    }

    toggleUtilityOptions() {
        const restrictedParkIds = ["6", "7"]
        const selectedParkId = this.parkTarget.value

        const gasOption = Array.from(this.utilityTarget.options).find(
            option => option.value === "Gas"
        )

        if (!gasOption) return

        if (restrictedParkIds.includes(selectedParkId)) {
            gasOption.hidden = true

            if (this.utilityTarget.value === "Gas") {
                this.utilityTarget.value = ""
            }
        } else {
            gasOption.hidden = false
        }
    }
}