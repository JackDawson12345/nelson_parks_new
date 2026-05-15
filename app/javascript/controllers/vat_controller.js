import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "select",
        "custom",
        "customContainer",
        "amount",
        "frequency",
        "net",
        "vatLabel",
        "vatTotal",
        "monthlySurchargeRow",
        "monthlySurcharge",
        "total"
    ]

    connect() {
        this.toggle({ preserveCustomValue: true })
        this.calculate()
    }

    toggle(options = {}) {
        const preserveCustomValue = options.preserveCustomValue || false

        if (this.selectTarget.value === "custom") {
            this.customContainerTarget.classList.remove("hidden")
            this.customTarget.disabled = false

            if (!preserveCustomValue && this.customTarget.value === "") {
                this.customTarget.focus()
            }
        } else {
            this.customContainerTarget.classList.add("hidden")
            this.customTarget.disabled = true

            if (!preserveCustomValue) {
                this.customTarget.value = ""
            }
        }

        this.calculate()
    }

    calculate() {
        const net = parseFloat(this.amountTarget.value) || 0
        const vatRate = this.vatRate()

        let monthlySurcharge = 0
        let adjustedNet = net

        if (this.hasFrequencyTarget && this.frequencyTarget.value === "Monthly") {
            monthlySurcharge = net * 0.15
            adjustedNet = net + monthlySurcharge

            if (this.hasMonthlySurchargeRowTarget) {
                this.monthlySurchargeRowTarget.classList.remove("hidden")
            }
        } else {
            if (this.hasMonthlySurchargeRowTarget) {
                this.monthlySurchargeRowTarget.classList.add("hidden")
            }
        }

        const vatTotal = adjustedNet * (vatRate / 100)
        const total = adjustedNet + vatTotal

        this.netTarget.textContent = this.money(adjustedNet)
        this.vatLabelTarget.textContent = `Vat (${this.formatRate(vatRate)}%)`
        this.vatTotalTarget.textContent = this.money(vatTotal)

        if (this.hasMonthlySurchargeTarget) {
            this.monthlySurchargeTarget.textContent = this.money(monthlySurcharge)
        }

        this.totalTarget.textContent = this.money(total)
    }

    vatRate() {
        if (this.selectTarget.value === "custom") {
            return parseFloat(this.customTarget.value) || 0
        }

        return parseFloat(this.selectTarget.value) || 0
    }

    money(value) {
        return new Intl.NumberFormat("en-GB", {
            style: "currency",
            currency: "GBP"
        }).format(value)
    }

    formatRate(value) {
        return Number.isInteger(value) ? value : value.toFixed(2)
    }
}