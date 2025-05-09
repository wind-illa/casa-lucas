import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["flashMessages"];

  connect() {
    if (this.flashMessagesTarget) {
      setTimeout(() => {
        this.flashMessagesTarget.style.display = 'none'; // Ocultar después de 5 segundos
      }, 5000); // 5000 milisegundos = 5 segundos
    }
  }

  hideFlashMessages() {
    this.flashMessagesTarget.style.display = 'none'; // Ocultar manualmente
  }
}
