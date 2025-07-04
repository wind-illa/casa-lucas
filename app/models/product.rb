class Product < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_full_text,
                  against: [:product_name, :sku], # Unificamos `against` para buscar en varios campos a la vez
                  associated_against: { bar_codes: :code },
                  using: {
                    tsearch: { prefix: true, normalization: 2 },
                    trigram: { threshold: 0.3 } # Ajusta el umbral según sea necesario
                  }

  belongs_to :category
  belongs_to :subcategory
  has_many :product_variants, dependent: :destroy
  has_many :order_items, dependent: :destroy  # Eliminamos los order_items asociados
  has_many :cart_items, dependent: :destroy    # Eliminamos los cart_items asociados

  has_many :list_items, dependent: :destroy
  has_many :lists, through: :list_items

  has_many :carts, through: :cart_items
  has_many :histories, dependent: :destroy
  has_many :viewers, through: :histories, source: :user

  # Callbacks
  before_validation :generate_unique_sku, on: :create
  has_many_attached :product_images

  # Relación uno a muchos con la tabla bar_codes
  has_many :bar_codes, dependent: :destroy
  accepts_nested_attributes_for :bar_codes, allow_destroy: true

  # Validaciones
  validates :subcategory, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true

  # Scopes
  scope :super_offers, -> { where('price_discount > ?', 0).order(price_discount: :desc) }

  scope :new_arrivals, -> { order(created_at: :desc).limit(20) }
  scope :best_sellers, -> {
    joins(:order_items)
      .group('products.id')
      .order('SUM(order_items.quantity) DESC')
      .limit(20)
  }

  # Generar SKU único
  def generate_unique_sku
    self.sku ||= loop do
      random_sku = SecureRandom.hex(4).upcase
      break random_sku unless Product.exists?(sku: random_sku)
    end
  end

  # Método para calcular precio con descuento

  def discounted_price
    return price if price_discount.nil? || price_discount <= 0
    price - (price * (price_discount / 100.0))
  end


end
