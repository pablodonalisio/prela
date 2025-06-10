class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  belongs_to :client, optional: true

  enum role: {client: 0, admin: 1}

  validates :role, presence: true
  validates :editor, inclusion: {in: [true, false]}

  def full_role
    case role
    when "admin" then "Admin"
    when "client" then "Cliente#{editor? ? " (Editor)" : ""}"
    else
      raise StandardError, "Undefined role"
    end
  end
end
