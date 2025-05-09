# app/services/shipping_calculators/andreani.rb
module ShippingCalculators
  class Andreani < ShippingCalculator
    def calculate_cost(address, weight)
      AndreaniService.calculate_shipping_cost(address, weight)
    end

    def description
      "El costo de envío se calcula en función de la dirección y el peso con Andreani."
    end
  end
end
