import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  connect() {
    window.onpageshow = (event) => {
      if (event.persisted) {
        window.location.reload(); // Recarga la página si ha sido restaurada desde caché
      }
    };
  }
}
