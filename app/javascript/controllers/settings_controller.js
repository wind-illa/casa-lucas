import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["formGroup", "inputField", "editButton", "saveButton"];

  connect() {
    // Nada adicional aquí por ahora
  }

  toggleEdit(event) {
    const formGroup = event.target.closest(".form-group");
    const inputField = formGroup.querySelector(".input-field");
    const saveButton = formGroup.querySelector(".btn-save");
    const editButton = formGroup.querySelector(".btn-edit");

    // Alterna entre edición y solo lectura
    inputField.disabled = false;
    saveButton.style.display = "inline-block";
    editButton.style.display = "none";
  }

  saveChanges(event) {
    const formGroup = event.target.closest(".form-group"); // Encuentra el formulario actual
    const form = formGroup.querySelector("form");
    const inputField = formGroup.querySelector(".input-field");
    const saveButton = formGroup.querySelector(".btn-save");
    const editButton = formGroup.querySelector(".btn-edit");

    // Usar Turbo para enviar el formulario sin recargar la página
    form.requestSubmit();

    // Después de enviar, deshabilitar el campo y ocultar el botón de guardar
    inputField.disabled = true;
    saveButton.style.display = "none";
    editButton.style.display = "inline-block";
  }


}
