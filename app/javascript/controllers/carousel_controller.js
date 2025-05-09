import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // Definimos los targets y los valores estáticos (intervalo y el índice actual del carrusel)
  static targets = ["carouselImages", "indicators"];
  static values = { currentIndex: Number, interval: { type: Number, default: 5000 } };

  // Inicialización: establece el índice inicial, inicia el desplazamiento automático, actualiza los indicadores y duplica los elementos del carrusel
  initialize() {
    this.currentIndexValue = 0;  // Inicia el índice del carrusel en 0
    this.startAutoSlide();       // Comienza el deslizamiento automático
    this.updateIndicators();     // Actualiza los indicadores visualmente
    this.duplicateCarouselItems(); // Duplica los elementos para permitir el bucle infinito
  }

  // Conectar eventos táctiles para permitir la navegación en dispositivos móviles
  connect() {
    // Se agregan los eventos de inicio, movimiento y finalización del toque
    this.carouselImagesTarget.addEventListener("touchstart", this.startTouch.bind(this));
    this.carouselImagesTarget.addEventListener("touchmove", this.moveTouch.bind(this));
    this.carouselImagesTarget.addEventListener("touchend", this.endTouch.bind(this));
  }

  // Función para duplicar el primer y el último elemento para crear un carrusel infinito
  duplicateCarouselItems() {
    // Obtener el primer y el último elemento del carrusel
    const firstItem = this.carouselImagesTarget.children[0];
    const lastItem = this.carouselImagesTarget.children[this.carouselImagesTarget.children.length - 1];

    // Clonamos el primer y último elemento y los agregamos al final y al principio del carrusel
    this.carouselImagesTarget.appendChild(firstItem.cloneNode(true));
    this.carouselImagesTarget.insertBefore(lastItem.cloneNode(true), this.carouselImagesTarget.firstChild);
  }

  // Función para iniciar el deslizamiento automático de las imágenes
  startAutoSlide() {
    this.stopAutoSlide();  // Primero detenemos cualquier temporizador anterior
    // Configuramos un temporizador para cambiar de imagen cada cierto intervalo (por defecto 5000 ms)
    this.autoSlideTimer = setInterval(() => this.goToNext(), this.intervalValue);
  }

  // Detener el deslizamiento automático
  stopAutoSlide() {
    clearInterval(this.autoSlideTimer);  // Limpiamos el temporizador para detener el cambio automático
  }

  // Reiniciar el deslizamiento automático, parando y luego comenzando de nuevo
  restartAutoSlide() {
    this.stopAutoSlide();  // Detener el desplazamiento
    this.startAutoSlide(); // Iniciar el desplazamiento nuevamente
  }

  // Manejo del inicio del toque en dispositivos táctiles
  startTouch(event) {
    // Guardamos la posición X inicial del toque
    this.startX = event.touches[0].clientX;
    this.stopAutoSlide(); // Detenemos el deslizamiento automático al comenzar el toque
  }

  // Manejo del movimiento del toque
  moveTouch(event) {
    // Guardamos la posición X final del toque durante el movimiento
    this.endX = event.touches[0].clientX;
  }

  // Manejo del final del toque
  endTouch() {
    const threshold = 50;  // Definimos el umbral mínimo de desplazamiento para cambiar de imagen
    if (this.startX - this.endX > threshold) {
      this.goToNext();  // Si el desplazamiento fue suficiente, vamos a la siguiente imagen
    } else if (this.endX - this.startX > threshold) {
      this.goToPrev();  // Si el desplazamiento fue al revés, vamos a la imagen anterior
    }
    this.restartAutoSlide();  // Reiniciamos el deslizamiento automático después del toque
  }

  // Función para navegar hacia la imagen anterior
  goToPrev() {
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--; // Decrementamos el índice si no estamos en la primera imagen
    } else {
      // Si estamos en la primera imagen duplicada, volvemos a la última imagen original
      this.currentIndexValue = this.carouselImagesTarget.children.length - 3;
    }
    this.updateCarousel();  // Actualizamos la posición del carrusel
  }

  // Función para navegar hacia la siguiente imagen
  goToNext() {
    const items = this.carouselImagesTarget.children;

    if (this.currentIndexValue < items.length - 1) {
      this.currentIndexValue++; // Incrementamos el índice si no hemos llegado al final
    } else {
      // Cuando llegamos al final del carrusel (última imagen duplicada), volvemos a la segunda imagen original
      this.currentIndexValue = 1;
      this.fixTransition();  // Solucionamos el "salto" antes de volver a la primera imagen
      this.updateIndicators(); // Aseguramos que los indicadores se actualicen antes de volver a la segunda imagen
    }

    this.updateCarousel();  // Actualizamos la posición del carrusel
  }

  fixTransition() {
    // Desactivamos momentáneamente la transición
    this.carouselImagesTarget.style.transition = "none";
    // Movemos directamente a la segunda imagen
    this.carouselImagesTarget.style.transform = "translateX(-100%)";
    // Forzamos un reflow (para que el navegador registre el cambio)
    this.carouselImagesTarget.offsetHeight;  // Leer el valor de offsetHeight fuerza el reflow
    // Restauramos la transición después de un breve retraso
    setTimeout(() => {
      this.carouselImagesTarget.style.transition = "transform 0.5s ease-in-out";
    }, 50);  // Un pequeño retraso para que se registre el cambio
  }


  // Función que actualiza la posición del carrusel y los indicadores visualmente
  updateCarousel() {
    const offset = -this.currentIndexValue * 100;  // Calculamos el desplazamiento en porcentaje
    this.carouselImagesTarget.style.transition = "transform 0.5s ease-in-out";  // Aplicamos una transición suave
    this.carouselImagesTarget.style.transform = `translateX(${offset}%)`;  // Aplicamos la transformación al carrusel

    // Actualizamos los indicadores de la imagen activa
    this.updateIndicators();
  }

  // Función para actualizar el estado de los indicadores
  updateIndicators() {
    // Total de elementos sin contar los duplicados
    const totalItems = this.carouselImagesTarget.children.length - 2;  // Restamos las imágenes duplicadas
    let adjustedIndex = this.currentIndexValue;

    // Si estamos en la imagen duplicada al final, ajustamos el índice
    if (adjustedIndex >= totalItems) {
      adjustedIndex = 0;  // Volvemos al primer indicador cuando llegamos a la última imagen duplicada
    }

    // Actualizamos los indicadores solo cuando no estamos en las imágenes duplicadas
    this.indicatorsTarget.querySelectorAll(".indicator").forEach((indicator, index) => {
      indicator.classList.toggle("active", index === adjustedIndex);  // Marcamos el indicador correspondiente como activo
    });
  }
}
