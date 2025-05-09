import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["carouselImages", "indicators", "prevButton", "nextButton"];
  static values = { currentIndex: Number, interval: { type: Number, default: 5000 } };

  initialize() {
    this.currentIndexValue = 0; // Iniciar en la primera imagen real (no duplicada)
    this.duplicateCarouselItems();
    this.updateCarousel();
    this.startAutoSlide();
  }

  connect() {
    this.prevButtonTarget.addEventListener('click', () => this.goToPrev());
    this.nextButtonTarget.addEventListener('click', () => this.goToNext());

    // Evento para detectar el fin de la transición y ajustar el índice sin transiciones bruscas
    this.carouselImagesTarget.addEventListener('transitionend', () => this.handleTransitionEnd());
  }

  duplicateCarouselItems() {
    const firstItem = this.carouselImagesTarget.children[0];
    const lastItem = this.carouselImagesTarget.children[this.carouselImagesTarget.children.length - 1];

    this.carouselImagesTarget.appendChild(firstItem.cloneNode(true));
    this.carouselImagesTarget.insertBefore(lastItem.cloneNode(true), this.carouselImagesTarget.firstChild);
  }

  startAutoSlide() {
    this.stopAutoSlide();
    this.autoSlideTimer = setInterval(() => this.goToNext(), this.intervalValue);
  }

  stopAutoSlide() {
    clearInterval(this.autoSlideTimer);
  }

  restartAutoSlide() {
    this.stopAutoSlide();
    this.startAutoSlide();
  }

  goToPrev() {
    this.currentIndexValue--;
    this.updateCarousel();
    this.restartAutoSlide();
  }

  goToNext() {
    this.currentIndexValue++;
    this.updateCarousel();
    this.restartAutoSlide();
  }

  handleTransitionEnd() {
    // Si estamos en el índice duplicado al final, salta al primer elemento real
    if (this.currentIndexValue >= this.carouselImagesTarget.children.length - 1) {
      this.carouselImagesTarget.style.transition = "none";
      this.currentIndexValue = 1;
      this.updateCarousel(false); // Sin transición
    }
    // Si estamos en el índice duplicado al inicio, salta al último elemento real
    else if (this.currentIndexValue <= 0) {
      this.carouselImagesTarget.style.transition = "none";
      this.currentIndexValue = this.carouselImagesTarget.children.length - 2;
      this.updateCarousel(false); // Sin transición
    }
  }

  updateCarousel(transition = true) {
    const offset = -this.currentIndexValue * 100;

    if (transition) {
      this.carouselImagesTarget.style.transition = "transform 0.5s ease-in-out";
    } else {
      this.carouselImagesTarget.style.transition = "none";
    }

    this.carouselImagesTarget.style.transform = `translateX(${offset}%)`;
    this.updateIndicators();
  }

  updateIndicators() {
    const totalItems = this.carouselImagesTarget.children.length - 2;
    let adjustedIndex = this.currentIndexValue;

    if (adjustedIndex >= totalItems) {
      adjustedIndex = 0;
    } else if (adjustedIndex <= 0) {
      adjustedIndex = totalItems - 1;
    }

    this.indicatorsTarget.querySelectorAll(".indicator").forEach((indicator, index) => {
      indicator.classList.toggle("active", index === adjustedIndex);
    });
  }

  disconnect() {
    this.stopAutoSlide();
  }
}
