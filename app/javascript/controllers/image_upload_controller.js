import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileInput", "imagePreview"];

  // Este arreglo se utiliza para almacenar los archivos seleccionados de manera acumulativa.
  files = [];

  // Abre el selector de archivos
  triggerUpload() {
    this.fileInputTarget.click();
  }

  // Maneja la subida de imágenes y muestra la vista previa
  handleImageUpload(event) {
    const newFiles = event.target.files;

    // Verifica si hay archivos nuevos antes de procesarlos
    if (newFiles?.length > 0) {
      this.addFilesToInput(newFiles);
      this.previewImages(newFiles);
    } else {
      // Restaura los archivos previamente cargados al input para evitar perderlos
      const dataTransfer = new DataTransfer();
      this.files.forEach(file => dataTransfer.items.add(file));
      this.fileInputTarget.files = dataTransfer.files;
    }
  }


  // Añade los nuevos archivos al input sin reemplazar los existentes
  addFilesToInput(newFiles) {
    const updatedFiles = [...this.files, ...Array.from(newFiles)];

    // Guardamos los archivos actualizados en el arreglo `files`
    this.files = updatedFiles;

    // Crear un objeto DataTransfer para manejar los archivos
    const dataTransfer = new DataTransfer();
    updatedFiles.forEach(file => dataTransfer.items.add(file));

    // Asignamos los archivos acumulados al input sin perder los anteriores
    this.fileInputTarget.files = dataTransfer.files;
  }

  // Genera vistas previas de las imágenes
  previewImages(files) {
    Array.from(files).forEach((file) => {
      // No agregar imágenes duplicadas a la vista previa
      if (!this.isImagePreviewed(file)) {
        const reader = new FileReader();
        reader.onload = (e) => {
          const imageContainer = document.createElement("div");
          imageContainer.classList.add("image-preview-item");
          imageContainer.innerHTML = `
            <img src="${e.target.result}" alt="${file.name}" class="image-preview-thumbnail">
            <button type="button" class="remove-image-btn" data-action="click->image-upload#removeImage">Eliminar</button>
          `;
          this.imagePreviewTarget.appendChild(imageContainer);
        };
        reader.readAsDataURL(file);
      }
    });
  }

  // Verifica si la imagen ya se ha previsualizado
  isImagePreviewed(file) {
    const previewedImages = Array.from(this.imagePreviewTarget.querySelectorAll('img'));
    return previewedImages.some((img) => img.alt === file.name); // Compara por el nombre del archivo
  }

  // Elimina una imagen de la vista previa y del input
  removeImage(event) {
    const imageElement = event.target.closest(".image-preview-item");
    if (!imageElement) return;

    const fileName = imageElement.querySelector('img').alt;
    const updatedFiles = this.files.filter(file => file.name !== fileName);

    // Actualizamos el arreglo `files` y el objeto `DataTransfer`
    this.files = updatedFiles;

    const dataTransfer = new DataTransfer();
    updatedFiles.forEach(file => dataTransfer.items.add(file));

    this.fileInputTarget.files = dataTransfer.files;
    imageElement.remove();
  }

  // Habilita el área para arrastrar y soltar archivos
  connect() {
    this.imagePreviewTarget.addEventListener('dragover', this.handleDragOver.bind(this));
    this.imagePreviewTarget.addEventListener('drop', this.handleDrop.bind(this));
  }

  // Previene el comportamiento por defecto al arrastrar un archivo sobre el área
  handleDragOver(event) {
    event.preventDefault();
    this.imagePreviewTarget.classList.add('drag-over');
  }

  // Maneja el archivo cuando se suelta sobre el área
  handleDrop(event) {
    event.preventDefault();
    this.imagePreviewTarget.classList.remove('drag-over');

    const newFiles = event.dataTransfer.files;
    if (newFiles?.length > 0) {
      this.addFilesToInput(newFiles);
      this.previewImages(newFiles);
    }
  }

  // Elimina la clase `drag-over` cuando el arrastre termina sin soltar un archivo
  disconnect() {
    this.imagePreviewTarget.removeEventListener('dragover', this.handleDragOver.bind(this));
    this.imagePreviewTarget.removeEventListener('drop', this.handleDrop.bind(this));
  }
}
