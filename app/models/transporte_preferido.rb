class TransportePreferido < ApplicationRecord
  belongs_to :user

  validates :nombre, presence: true

  before_save :asegurar_unico_predeterminado

  private


  def asegurar_unico_predeterminado
    return unless predeterminado?

    TransportePreferido.where(user_id: user_id, predeterminado: true)
                       .where.not(id: id)
                       .update_all(predeterminado: false)
  end
end
