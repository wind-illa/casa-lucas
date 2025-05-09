class Order < ApplicationRecord
  include PgSearch::Model
  belongs_to :user
  belongs_to :shipping_method, optional: true
  belongs_to :payment_method, optional: true
  belongs_to :address, optional: true
  has_many :order_items, dependent: :destroy
  has_one_attached :comprobante


  # Búsqueda en nombre del comprador, correo, y ID de orden
  pg_search_scope :search_full_text,
  against: [:id, :mercado_pago_transaction_id], # Buscar por ID de la orden
  associated_against: {
    user: [:first_name, :email, :last_name]
  },
  using: {
    tsearch: { prefix: true, normalization: 2 },
    trigram: { threshold: 0.3 }
  }


  enum status: {
    pendiente: 0,           # El pedido fue creado pero no se ha procesado
    pago_pendiente: 1,      # El pedido está listo, pero el pago está pendiente (pago en tienda o contra entrega)
    pagado: 2,              # El pago fue confirmado
    en_preparacion: 3,      # El pedido está siendo preparado
    listo_para_retirar: 4,  # El pedido está listo para ser retirado en tienda (si aplica)
    enviado: 5,             # El pedido fue enviado al cliente
    entregado: 6,           # El pedido fue entregado al cliente
    cancelado: 7,           # El pedido fue cancelado
  }


  validates :status, presence: true
  before_validation :set_default_status, on: :create


  private


  def set_default_status
    self.status ||= :pendiente
  end


end
