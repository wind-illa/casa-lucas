
//javascript/controllers/avatar_profiles_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "desktopPreview", "mobilePreview"]

  preview(event) {
    const file = this.inputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        // Aquí ya no usamos outputTarget
        // Si deseas hacer algo con la imagen, puedes usar desktopPreview o mobilePreview
      }
      reader.readAsDataURL(file)

      // Puedes agregar una función para enviar el formulario automáticamente después de que la imagen se haya seleccionado
      this.submitForm()
    }
  }

  selectFile() {
    // Simula un clic en el input de archivo cuando se hace clic en la imagen
    this.inputTarget.click()
  }

  submitForm() {
    // Envía el formulario automáticamente al servidor
    this.element.requestSubmit()
  }

  // NUEVAS FUNCIONES PARA LA VISTA PREVIA DE IMÁGENES
  previewDesktopImage(event) {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.desktopPreviewTarget.style.backgroundImage = `url(${e.target.result})`
        this.desktopPreviewTarget.style.backgroundSize = 'cover'
        this.desktopPreviewTarget.style.backgroundPosition = 'center'
        this.desktopPreviewTarget.style.height = '200px'  // Ajustar el tamaño de la vista previa
      }
      reader.readAsDataURL(file)
    }
  }

  previewMobileImage(event) {
    const file = event.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.mobilePreviewTarget.style.backgroundImage = `url(${e.target.result})`
        this.mobilePreviewTarget.style.backgroundSize = 'cover'
        this.mobilePreviewTarget.style.backgroundPosition = 'center'
        this.mobilePreviewTarget.style.height = '200px'  // Ajustar el tamaño de la vista previa
      }
      reader.readAsDataURL(file)
    }
  }
}
