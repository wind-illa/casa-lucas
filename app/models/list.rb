class List < ApplicationRecord
  belongs_to :user              # Cada lista pertenece a un usuario (dueño)
  has_many :list_items, dependent: :destroy  # Una lista tiene muchos ítems (productos en la lista)
  has_many :products, through: :list_items   # Asociación indirecta a productos a través de list_items

  validates :name, presence: true  # Validación para que el nombre no esté vacío
end
