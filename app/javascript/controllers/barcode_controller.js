import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template", "container"];

  add(event) {
    event.preventDefault();
    const template = this.templateTarget.content.cloneNode(true);

    // Generar un índice único basado en la cantidad de elementos ya presentes
    const index = this.containerTarget.querySelectorAll('.barcode-fields').length;

    // Modificar el nombre del campo de código de barras para que tenga un índice único
    const inputField = template.querySelector('input[name*="bar_codes_attributes"]');
    if (inputField) {
      inputField.name = `product[bar_codes_attributes][${index}][code]`; // Asignar nombre con índice único
    }

    // Si también hay un campo oculto (_destroy), cambiar su nombre para que tenga un índice único
    const destroyField = template.querySelector('input[name*="_destroy"]');
    if (destroyField) {
      destroyField.name = `product[bar_codes_attributes][${index}][_destroy]`; // Asignar nombre con índice único
    }

    // Añadir el nuevo campo al contenedor
    this.containerTarget.appendChild(template);

    console.log(this.containerTarget); // Puedes eliminar esta línea una vez verificado
  }

  remove(event) {
    event.preventDefault();
    const field = event.target.closest(".barcode-fields");
    field.querySelector('input[name*="_destroy"]').value = "1";
    field.style.display = "none";
  }
}
