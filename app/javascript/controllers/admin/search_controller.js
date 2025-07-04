import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "clearButton"];

  connect() {
    this.toggleClearButton();
  }

  toggleClearButton() {
    // Comprobar si el input y el clearButton existen
    if (this.hasInputTarget && this.hasClearButtonTarget) {
      // Mostrar u ocultar el botón clear según el contenido del input
      if (this.inputTarget.value.trim() !== "") {
        this.clearButtonTarget.style.display = "block";
      } else {
        this.clearButtonTarget.style.display = "none";
      }

    }
  }

  clearSearch(event) {
    // Remover el parámetro query_text de la URL si está presente
    const currentUrl = new URL(window.location);
    if (currentUrl.searchParams.has("query_text")) {
      currentUrl.searchParams.delete("query_text");

      // Actualizar la URL sin recargar la página
      window.history.pushState({}, '', currentUrl);
    }

    // Recargar la página para restablecer las subcategorías a su estado inicial
    window.location.reload();
  }
}
