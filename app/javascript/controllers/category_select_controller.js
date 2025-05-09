// app/javascript/controllers/category_select_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["subcategorySelect"]

  connect() {
    const categoryId = document.getElementById("category_id").value;
    const subcategoryId = this.subcategorySelectTarget.dataset.selectedSubcategory;

    if (categoryId) {
      this.loadSubcategoriesOnLoad(categoryId, subcategoryId);
    }
  }

  loadSubcategories(event) {
    const categoryId = event.target.value;
    this.loadSubcategoriesOnLoad(categoryId, null);
  }

  loadSubcategoriesOnLoad(categoryId, selectedSubcategory) {
    const subcategorySelect = this.subcategorySelectTarget;

    if (!categoryId) {
      subcategorySelect.disabled = true;
      subcategorySelect.style.display = "none";
      subcategorySelect.innerHTML = "<option value=''>Selecciona una subcategoría</option>";
      return;
    }

    fetch(`/admin/products/load_subcategories?category_id=${categoryId}`)
      .then(response => response.json())
      .then(subcategories => {
        subcategorySelect.disabled = false;
        subcategorySelect.style.display = "block";
        subcategorySelect.innerHTML = "<option value=''>Selecciona una subcategoría</option>";

        subcategories.forEach(subcategory => {
          const option = document.createElement("option");
          option.value = subcategory.id;
          option.textContent = subcategory.subcategory_name;
          if (selectedSubcategory && subcategory.id === parseInt(selectedSubcategory)) {
            option.selected = true;
          }
          subcategorySelect.appendChild(option);
        });
      })
      .catch(error => console.error("Error cargando las subcategorías:", error));
  }
}
