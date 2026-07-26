class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  belongs_to :client, optional: true

  enum :role, {:client=>0, :admin=>1}

  validates :role, presence: true
  validates :editor, inclusion: {in: [true, false]}

  scope :with_kept_client, -> {
    left_joins(:client).where("users.client_id IS NULL OR clients.discarded_at IS NULL")
  }

  def active_for_authentication?
    super && client_kept_for_authentication?
  end

  def inactive_message
    client_discarded_for_authentication? ? :client_discarded : super
  end

  def full_role
    case role
    when "admin" then "Admin"
    when "client" then "Cliente#{editor? ? " (Editor)" : ""}"
    else
      raise StandardError, "Undefined role"
    end
  end

  private

  def client_kept_for_authentication?
    admin? || client_id.nil? || client&.kept?
  end

  def client_discarded_for_authentication?
    client_id.present? && client&.discarded?
  end
end

