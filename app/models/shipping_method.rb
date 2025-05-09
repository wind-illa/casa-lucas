class ShippingMethod < ApplicationRecord
  has_many :orders

  # Validaciones
  validates :name, presence: true
  validates :cost, presence: true, if: -> { calculation_type == "static" }
  validates :calculation_type, presence: true, inclusion: { in: %w[static correo_argentino andreani] }

  # Retorna la clase de cálculo de costos según el tipo de método de envío
  def calculator
    case calculation_type
    when "static"
      ShippingCalculators::Static.new(cost, description)
    when "correo_argentino"
      ShippingCalculators::CorreoArgentino.new
    when "andreani"
      ShippingCalculators::Andreani.new
    else
      raise ArgumentError, "Tipo de método de envío no válido: #{calculation_type}"
    end
  end

  # Indica si el cálculo del costo es dinámico (requiere API externa)
  def dynamic?
    calculation_type.in?(%w[correo_argentino andreani])
  end
end


