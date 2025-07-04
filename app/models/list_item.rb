class ListItem < ApplicationRecord
  belongs_to :list          # Cada ítem pertenece a una lista
  belongs_to :product       # Cada ítem referencia un producto

  # Validación para evitar agregar dos veces el mismo producto a una lista
  validates :product_id, uniqueness: { scope: :list_id }
end
