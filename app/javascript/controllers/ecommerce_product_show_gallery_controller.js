





import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mainImage", "thumbnail", "variantImages"];  // Eliminamos 'variantIdField'

  connect() {
    this.setInitialSelectedThumbnail();
  }

  changeMainImage(event) {
    const newSrc = event.target.src;
    this.mainImageTarget.src = newSrc;
    this.updateSelectedThumbnail(event.target);
  }

  setInitialSelectedThumbnail() {
    const currentMainImageSrc = this.mainImageTarget.src;
    this.thumbnailTargets.forEach(thumbnail => {
      const isSelected = currentMainImageSrc.includes(thumbnail.src);
      thumbnail.parentElement.classList.toggle("selected", isSelected);
    });
  }

  changeVariantImages(event) {
    const variantId = event.target.dataset.variantId;
    const variantImages = this.variantImagesTargets.find(variant => variant.dataset.variantId == variantId);

    if (variantImages) {
      this.mainImageTarget.src = variantImages.querySelector(".variant-image").src;
      this.updateThumbnails(variantImages);
    }

    // Eliminamos la línea que intenta modificar 'variantIdFieldTarget'
    // this.variantIdFieldTarget.value = variantId;

    this.dispatch("variantChanged", { variantId });
  }

  resetToProductImages(event) {
    event.preventDefault();

    // Restablecer la imagen principal
    this.mainImageTarget.src = this.mainImageTarget.dataset.productMainImage;

    // Restablecer las miniaturas
    this.thumbnailTargets.forEach((thumbnail) => {
      // Restablecer la miniatura a la imagen del producto original
      thumbnail.src = thumbnail.dataset.thumbnailImage;
      thumbnail.parentElement.classList.remove("selected");
    });

    // Aseguramos que la primera miniatura quede seleccionada, como en el producto original
    if (this.thumbnailTargets[0]) {
      this.thumbnailTargets[0].parentElement.classList.add("selected");
    }

    // Actualizar las miniaturas para que coincidan con la imagen principal
    this.updateThumbnails(this.mainImageTarget.closest(".product-images"));
  }


  highlightSelectedVariant(event) {
    this.element.querySelectorAll(".variant").forEach(variant => variant.classList.remove("selected-variant"));
    event.currentTarget.classList.add("selected-variant");
  }

  updateThumbnails(variantImages) {
    const variantThumbnailImages = variantImages.querySelectorAll(".variant-thumbnail-image");

    this.thumbnailTargets.forEach((thumbnail, index) => {
      const newThumbnailSrc = variantThumbnailImages[index]?.src;
      if (newThumbnailSrc) {
        thumbnail.src = newThumbnailSrc;
        thumbnail.parentElement.classList.remove("selected");
      }
    });

    if (variantThumbnailImages[0]) {
      this.thumbnailTargets[0].src = variantThumbnailImages[0].src;
      this.thumbnailTargets[0].parentElement.classList.add("selected");
    }
  }

  updateSelectedThumbnail(target) {
    this.thumbnailTargets.forEach(thumbnail => thumbnail.parentElement.classList.remove("selected"));
    target.parentElement.classList.add("selected");
  }
}
