module ApplicationHelper

  def translated_resource_name(resource)
    case resource
    when 'user'
      'usuario'
    else
      resource.humanize  # Para otros recursos
    end
  end

  def formato_precio(price)
    number_to_currency(price, locale: :es)
  end

end

# <%= formato_precio(product.price) %>
