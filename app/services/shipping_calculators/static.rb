# app / services / shipping_calculators / static.rb
module ShippingCalculators
  class Static < ShippingCalculator
    def initialize(cost, description)
      @cost = cost
      @description = description
    end

    def calculate_cost(_address, _weight)
      @cost
    end

    def description
      @description
    end
  end
end
