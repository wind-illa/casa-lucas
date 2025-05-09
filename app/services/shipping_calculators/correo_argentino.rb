# app/services/shipping_calculators/correo_argentino.rb
module ShippingCalculators
  class CorreoArgentino < ShippingCalculator
    def calculate_cost(address, weight)
      CorreoArgentinoService.calculate_shipping_cost(address, weight)
    end

    def description
      "El costo de envío se calcula en función de la dirección y el peso con Correo Argentino."
    end
  end
end
