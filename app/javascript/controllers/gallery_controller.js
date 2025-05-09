import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mainImage", "thumbnail", "variant"];

  connect() {
    console.log("Gallery controller connected");

  }

  changeVariant(event) {
    const variantElement = event.currentTarget;
    const images = JSON.parse(variantElement.dataset.images);
    const variantColor = variantElement.dataset.color; // Nombre de la variante

    // Cambiar la imagen principal
    if (images.length > 0) {
      this.mainImageTarget.src = images[0];
    }

    // Actualizar el nombre de la variante seleccionada
    const variantNameElement = document.getElementById("variant-name");
    if (variantNameElement) {
      variantNameElement.textContent = variantColor;
    }

    // Marcar la miniatura de variante seleccionada como activa
    this.variantTargets.forEach((variant) => {
      variant.classList.remove("active");
    });
    variantElement.classList.add("active");

    // Actualizar miniaturas específicas de la variante seleccionada
    this.updateThumbnails(images);
  }

  changeImage(event) {
    const thumbnailElement = event.currentTarget;
    const imageUrl = thumbnailElement.dataset.imageUrl;

    // Cambiar la imagen principal
    this.mainImageTarget.src = imageUrl;

    // Marcar la miniatura seleccionada como activa
    this.thumbnailTargets.forEach((thumbnail) => {
      thumbnail.classList.remove("active");
    });
    thumbnailElement.classList.add("active");
  }

  updateThumbnails(images) {
    const thumbnailsContainer = this.thumbnailTarget.parentElement;

    // Limpiar todas las miniaturas antes de actualizar
    thumbnailsContainer.innerHTML = "";

    // Crear nuevas miniaturas basadas en las imágenes proporcionadas
    images.forEach((imageUrl, index) => {
      const thumbnailDiv = document.createElement("div");
      thumbnailDiv.className = `content-image ${index === 0 ? "active" : ""}`;
      thumbnailDiv.dataset.imageUrl = imageUrl;
      thumbnailDiv.dataset.galleryTarget = "thumbnail";
      thumbnailDiv.dataset.action = "click->gallery#changeImage";

      const thumbnailImg = document.createElement("img");
      thumbnailImg.src = imageUrl;
      thumbnailImg.alt = `Miniatura ${index + 1}`;
      thumbnailDiv.appendChild(thumbnailImg);

      thumbnailsContainer.appendChild(thumbnailDiv);
    });
  }
}

