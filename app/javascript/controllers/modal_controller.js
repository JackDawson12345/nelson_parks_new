import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    open(event) {
        const modalId = event.currentTarget.dataset.modalId
        document.getElementById(modalId).classList.remove("hidden")
    }

    close(event) {
        event.currentTarget.closest("[data-modal]").classList.add("hidden")
    }
}