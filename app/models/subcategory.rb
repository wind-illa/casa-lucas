class Subcategory < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_full_text,
                  against: :subcategory_name,
                  using: {
                    tsearch: { prefix: true, normalization: 2 },
                    trigram: { threshold: 0.3 } # Ajusta el umbral según sea necesario
                  }



  belongs_to :category
  has_many :products, dependent: :destroy

  # Validaciones
  validates :subcategory_name, presence: true, uniqueness: { scope: :category_id, message: "ya existe dentro de esta categoría" }, length: { maximum: 100 }
  validates :subcategory_name, presence: { message: "El nombre de la subcategoría es obligatorio." }
  validates :subcategory_image, presence: { message: "La imagen de la subcategoría es obligatoria." }



  # CLOUDINARY
  has_one_attached :subcategory_image


end
