// javascript/controllers/carousel_historial_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["wrapper", "pagination"];
  currentIndex = 0;

  connect() {
    // Verifica que los elementos necesarios estén presentes
    if (!this.hasWrapperTarget || !this.hasPaginationTarget) {
      console.error("Faltan elementos necesarios: wrapper o pagination");
      return;
    }

    this.totalItems = this.wrapperTarget.children.length;
    this.itemsPerPage = 6; // Cantidad de elementos visibles por página
    this.totalPages = Math.ceil(this.totalItems / this.itemsPerPage);

    // Crea los indicadores de paginación
    this.renderPagination();
    this.updatePagination();

     // Actualiza la visibilidad de los controles (prev y next)
    this.updateControlsVisibility();
  }

  prev() {
    this.currentIndex = Math.max(this.currentIndex - this.itemsPerPage, 0);
    this.updateCarousel();
  }

  next() {
    this.currentIndex = Math.min(
      this.currentIndex + this.itemsPerPage,
      (this.totalPages - 1) * this.itemsPerPage
    );
    this.updateCarousel();
  }

  updateCarousel() {
    const offset = -this.currentIndex * 194; // Ancho del producto
    this.wrapperTarget.style.transform = `translateX(${offset}px)`;
    this.updatePagination();
    this.updateControlsVisibility(); // Llama a la función para actualizar visibilidad de los controles
  }

  updateControlsVisibility() {
    // Mostrar u ocultar el botón "prev"
    const prevButton = document.querySelector('.andes-carousel-snapped__control--prev');
    if (this.currentIndex === 0) {
      prevButton.classList.add('hidden'); // Ocultar el botón "prev"
    } else {
      prevButton.classList.remove('hidden'); // Mostrar el botón "prev"
    }

    // Mostrar u ocultar el botón "next"
    const nextButton = document.querySelector('.andes-carousel-snapped__control--next');
    if (this.currentIndex >= (this.totalPages - 1) * this.itemsPerPage) {
      nextButton.classList.add('hidden'); // Ocultar el botón "next"
    } else {
      nextButton.classList.remove('hidden'); // Mostrar el botón "next"
    }
  }


  updatePagination() {
    if (!this.paginationTarget.children.length) {
      console.warn("No hay elementos de paginación");
      return;
    }

    // Itera sobre los indicadores de paginación
    Array.from(this.paginationTarget.children).forEach((node, index) => {
      node.classList.toggle(
        "active",
        index === Math.floor(this.currentIndex / this.itemsPerPage)
      );
    });
  }

  renderPagination() {
    // Limpia los indicadores actuales
    this.paginationTarget.innerHTML = "";

    // Crea un indicador por cada página
    for (let i = 0; i < this.totalPages; i++) {
      const indicator = document.createElement("div");
      indicator.dataset.index = i; // Agrega el índice de la página
      indicator.classList.add("pagination-indicator"); // Usa estilos existentes
      this.paginationTarget.appendChild(indicator);
    }
  }
}
