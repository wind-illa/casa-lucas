 import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "item"]

  hideItem() {
    if (this.checkboxTarget.checked) {
      this.itemTarget.style.display = "none";
    } else {
      this.itemTarget.style.display = "flex";
    }
  }
}




