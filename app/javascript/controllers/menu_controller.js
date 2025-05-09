import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["background", "modal", "backgrounduser", "modaluser"]

  // modal menu
  open() {
    this.modalTarget.classList.add('is-open')
    this.backgroundTarget.classList.add('is-open')
  }

  close() {
    this.modalTarget.classList.remove("is-open")
    this.backgroundTarget.classList.remove("is-open")
  }

  // modal user

  openUser() {
    this.modaluserTarget.classList.add('is-open')
    this.backgrounduserTarget.classList.add('is-open')
  }

  closeUser() {
    this.modaluserTarget.classList.remove("is-open")
    this.backgrounduserTarget.classList.remove("is-open")
  }
}
