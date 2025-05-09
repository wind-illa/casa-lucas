require 'prawn'
require 'prawn/table'

class OrderPdf < Prawn::Document
  def initialize(order)
    super()
    @order = order
    header
    order_details
    order_items
  end

  def header
    font "Helvetica" # Usar una fuente más moderna
    text "Orden de Compra ##{@order.id}", size: 18, style: :bold, align: :center, color: "000000"
    move_down 10
    text "Fecha: #{@order.created_at.strftime('%d/%m/%Y')}", size: 12, align: :right, color: "555555"
    move_down 20
  end

  def order_details
    font "Helvetica"
    text "Detalles del Cliente:", size: 16, style: :bold, color: "333333"
    move_down 5

    text "Nombre: #{@order.user.full_name.truncate(25, omission: '...')}", size: 12, color: "555555"
    text "Email: #{@order.user.email.truncate(30, omission: '...')}", size: 12, color: "555555"
    text "Teléfono: #{@order.user.phone}", size: 12, color: "555555"

    move_down 20
  end

  def order_items
    font "Helvetica"
    text "Productos:", size: 14, style: :bold, color: "333333"
    move_down 10

    table_data = [["Producto", "Cantidad", "Precio Unitario", "Total"]]

    @order.order_items.each do |item|
      table_data << [
        item.product.product_name.truncate(25, omission: '...'),
        item.quantity,
        "$#{'%.0f' % item.price}",
        "$#{'%.0f' % (item.price * item.quantity)}"
      ]
    end

    # Crear tabla sin bordes visibles y con espaciado
    table table_data, header: true, width: bounds.width, cell_style: { borders: [] } do
      row(0).font_style = :bold
      self.row_colors = ["F9F9F9", "FFFFFF"]
      self.header = true
    end

    move_down 20
    text "Total: $#{'%.0f' % @order.total_price}", size: 16, style: :bold, align: :right, color: "333333"
  end
end
