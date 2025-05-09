class Banner < ApplicationRecord
  has_many_attached :desktop_images
  has_many_attached :mobile_images
  

  # Validaciones
  validates :title, presence: { message: "El título es obligatorio" }
  validates :desktop_images, presence: { message: "La imagen de escritorio es obligatoria" }
  validates :desktop_links, presence: { message: "El enlace de escritorio es obligatorio" }
  validates :mobile_images, presence: { message: "La imagen de móvil es obligatoria" }
  validates :mobile_links, presence: { message: "El enlace de móvil es obligatorio" }
end
