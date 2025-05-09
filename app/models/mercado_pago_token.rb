class MercadoPagoToken < ApplicationRecord
  enum estado: { activo: 0, inactivo: 1, no_vigente: 2 }

  validates :token, presence: true
  validates :estado, presence: true
  validates :nombre, presence: true
end
