class Category < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_full_text,
                  against: :category_name,
                  using: {
                    tsearch: { prefix: true, normalization: 2 },
                    trigram: { threshold: 0.3 } # Ajusta el umbral según sea necesario
                  }

  # Asociaciones
  has_many :subcategories, dependent: :destroy

  # Cloudinary
  has_one_attached :category_image

  # Validaciones
  validates :category_name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :category_image, presence: true

end
