// controlador de Stimulus para mostrar y ocultar secciones en el show de users
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["addresses", "orders", "cart", "button"];

  connect() {
    // Muestra inicialmente la sección "addresses"
    this.showSection("addresses");
  }

  show(event) {
    event.preventDefault();
    const section = event.currentTarget.dataset.section;
    this.showSection(section);
  }

  showSection(section) {
    // Oculta todas las secciones
    this.addressesTarget.classList.add("hidden");
    this.ordersTarget.classList.add("hidden");
    this.cartTarget.classList.add("hidden");

    // Muestra la sección correspondiente si existe
    const target = this[`${section}Target`];
    if (target) {
      target.classList.remove("hidden");
    } else {
      console.error(`No se encontró la sección: ${section}`);
    }

    // Actualiza los botones activos
    this.buttonTargets.forEach(button => {
      button.classList.toggle("active", button.dataset.section === section);
    });
  }
}
