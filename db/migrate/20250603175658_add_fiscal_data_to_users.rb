class AddFiscalDataToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :razon_social, :string            # Si factura a nombre de empresa o como nombre completo
    add_column :users, :cuit, :string                    # CUIT del cliente
    add_column :users, :condicion_fiscal, :integer, default: 1  # 0: Responsable Inscripto, 1: Consumidor Final, etc.
  end
end
