# app/services/shipping_calculator.rb
class ShippingCalculator
  # Este método debe ser implementado en las subclases
  def calculate_cost(address, weight)
    raise NotImplementedError, "Debes implementar este método en una subclase"
  end

  # Este método debe ser implementado en las subclases
  def description
    raise NotImplementedError, "Debes implementar este método en una subclase"
  end
end
