class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  include PgSearch::Model
  pg_search_scope :search_full_text,
                  against: [
                    :email, :first_name, :last_name,
                    :document_id, :phone
                  ],
                  using: {
                    tsearch: { prefix: true, normalization: 2 },
                    trigram: { threshold: 0.3 }
                  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # ASSOCIATIONS
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :viewed_products, through: :histories, source: :product
  has_one :cart, dependent: :destroy

  # CLOUDINARY
  has_one_attached :profile_picture

  # VALIDATIONS
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :email, presence: true
  validates :document_id, uniqueness: true, allow_nil: true
  validates :password, presence: true, confirmation: true, if: :password_required?


  enum :role, { administrador: 0, repositor: 1, cajero: 2, cliente: 3 }, default: :cliente
  enum :document_type, { DNI: 0, CUIL: 1, CUIT: 2, PASSPORT: 3 }



  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def password_required?
    new_record? || password.present?
  end

end
