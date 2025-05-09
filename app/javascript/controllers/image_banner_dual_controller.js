import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "fileInput"];

  // Abre el selector de archivos cuando se hace clic en la imagen
  openFileInput(event) {
    event.preventDefault();
    this.fileInputTarget.click();
  }

  // Muestra la imagen seleccionada en la vista previa
  previewImage(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        this.imageTarget.src = reader.result;
      };
      reader.readAsDataURL(file);
    }
  }
}
