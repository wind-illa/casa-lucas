// javascript/controllers/filter_category_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list", "item", "button"];

  // Inicialización (puedes agregar alertas o cualquier lógica de depuración si es necesario)
  connect() {
    console.log("Controller de filtro conectado.");
    console.log(this.inputTarget);  // Verifica si `inputTarget` se está cargando correctamente

  }

  // Función de búsqueda (se llama tanto con el evento de entrada como al hacer clic en el botón de búsqueda)
  search() {
    const query = this.inputTarget.value.toLowerCase().trim();

    // Filtrar las subcategorías según el texto ingresado
    this.itemTargets.forEach((item) => {
      const name = item.dataset.name.toLowerCase();
      if (name.includes(query)) {
        item.style.display = "block"; // Mostrar la subcategoría si coincide
      } else {
        item.style.display = "none"; // Ocultar la subcategoría si no coincide
      }
    });
  }

  // Activar búsqueda al presionar el botón de búsqueda
  triggerSearch() {
    this.search(); // Llamar a la función de búsqueda
  }
}
