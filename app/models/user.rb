class User < ApplicationRecord
  # EXTENSIONS
  include PgSearch::Model
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # SEARCH
  pg_search_scope :search_full_text,
                  against: [:email, :first_name, :last_name, :document_id, :phone, :id],
                  using: {
                    tsearch: { prefix: true, normalization: 2 },
                    trigram: { threshold: 0.3 }
                  }

  # ASSOCIATIONS
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :transporte_preferidos, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :viewed_products, through: :histories, source: :product
  has_one :cart, dependent: :destroy

  # FILE ATTACHMENTS
  has_one_attached :profile_picture
  has_one_attached :constancia_fiscal

  # ENUMS
  enum :role, {
    administrador: 0,
    repositor: 1,
    cajero: 2,
    cliente_regular: 3,
    cliente_mayorista: 4
  }, default: :cliente_regular

  enum :document_type, {
    DNI: 0,
    CUIL: 1,
    CUIT: 2,
  }

  enum :condicion_fiscal, {
    consumidor_final: 0,
    responsable_inscripto: 1,
    monotributista: 2,
    exento: 3
  }, default: :consumidor_final

  enum :status, {
    habilitado: 0,
    inhabilitado: 1
  }

  # VALIDATIONS
  validates :first_name, :last_name, :phone, :email, presence: true
  validates :document_id, uniqueness: true, allow_nil: true
  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  # METHODS
  private

  def password_required?
    new_record? || password.present?
  end
end
