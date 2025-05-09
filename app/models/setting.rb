class Setting < ApplicationRecord

  # Validaciones
  validates :iva_percentage, :profit_margin_ecommerce, :profit_margin_business, :dollar_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :price_input_type, inclusion: { in: ["purchase", "final_price"] }

  # Asegurar que solo exista una configuración en la base de datos
  validate :single_record

  private

  def single_record
    if Setting.exists? && self.new_record?
      errors.add(:base, "Solo puede existir un registro de configuración.")
    end
  end
end
