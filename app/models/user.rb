class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  belongs_to :client, optional: true

  enum role: {client: 0, admin: 1}

  validates :role, presence: true

  def location_equipments
    admin? ? LocationEquipment.all : client.location_equipments
  end
end
