import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="uploader-view-image-single"
export default class extends Controller {
  static targets = ["fileInput", "imageContainer", "previewImage", "placeholder"];

  uploadImage() {
    this.fileInputTarget.click(); // Abre el selector de archivos cuando el usuario hace clic
  }

  connect() {
    this.fileInputTarget.addEventListener("change", this.preview.bind(this));
  }

  preview(event) {
    const file = event.target.files[0];
    if (file) {
      // Crear la URL de la imagen seleccionada
      const reader = new FileReader();
      reader.onload = (e) => {
        // Si hay una imagen previa, reemplázala
        if (this.hasPreviewImageTarget) {
          this.previewImageTarget.src = e.target.result;
        } else {
          // Si no hay imagen previa, elimina el placeholder y añade la imagen
          this.placeholderTarget.remove();
          const img = document.createElement("img");
          img.src = e.target.result;
          img.classList.add("image-preview-thumbnail");
          img.dataset.uploaderViewImageSingleTarget = "previewImage";
          this.imageContainerTarget.appendChild(img);
        }
      };
      reader.readAsDataURL(file);
    }
  }
}
