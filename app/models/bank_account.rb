
class BankAccount < ApplicationRecord
  # Validaciones
  validates :tipo, presence: true
  validates :numero, presence: true, length: { is: 22 } # CBU y CVU tienen 22 dígitos
  validates :alias, presence: true, uniqueness: true

  enum estado: { activo: 0, inactivo: 1 }
  enum tipo: { cbu: 0, cvu: 1 }
end
