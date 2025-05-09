class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items




  def total_items
    cart_items.sum(:quantity)
  end



  def total_price
    # Calcula el subtotal sumando el precio de cada producto con su descuento individual
    subtotal = cart_items.includes(:product).sum do |item|
      product_price = item.product.price
      discount = item.product.price_discount || 0
      discounted_price = product_price - (product_price * discount / 100.0)
      discounted_price * item.quantity
    end

    # Busca el rango de descuento aplicable según el subtotal
    applicable_discount_range = DiscountRange.where("min_amount <= ?", subtotal)
                                               .order(min_amount: :desc)
                                               .first

    discount_percentage = 0
    subtotal_with_discount = subtotal

    if applicable_discount_range
      discount_percentage = applicable_discount_range.discount_percentage
      discount_amount = subtotal * (discount_percentage / 100.0)
      subtotal_with_discount = subtotal - discount_amount
    end

    {
      subtotal: subtotal,
      discount_percentage: discount_percentage,
      subtotal_with_discount: subtotal_with_discount
    }
  end

end
