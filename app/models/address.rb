class Address < ApplicationRecord
  belongs_to :user

  validates :street_name, :street_number, :locality, :city, :postal_code, presence: true
  enum :address_type, { direccion_envio: 0, direccion_fiscal: 1 }, default: :direccion_envio

  before_save :ensure_only_one_default_shipping


  def full_address
    [street_name, street_number, postal_code].compact.join(', ')
  end

  private

  def ensure_only_one_default_shipping
    return unless default_shipping?
    # Desmarcar las demás direcciones del usuario
    Address.where(user_id: user_id, default_shipping: true).where.not(id: id).update_all(default_shipping: false)
  end

end
