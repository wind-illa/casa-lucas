class Address < ApplicationRecord
  belongs_to :user

  validates :street_name, :street_number, :locality, :city, :postal_code, presence: true

  def full_address
    [street_name, street_number, postal_code].compact.join(', ')
  end

  def full_address
    [street_name, street_number, postal_code].compact.join(', ')
  end
end
