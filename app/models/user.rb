class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :accounts, dependent: :destroy
  has_many :transactions, through: :accounts
  has_many :categories, dependent: :destroy
  # has_many :user_roles # Optional, if implementing roles
  # has_many :roles, through: :user_roles # Optional, if implementing roles

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :language, presence: true, inclusion: { in: %w(en pt-BR), message: "%{value} is not a valid language" }
  validates :time_zone, presence: true # Consider adding a list of valid time zones if needed
  validates :currency, presence: true, inclusion: { in: %w(USD BRL EUR GBP), message: "%{value} is not a valid currency" } # Add more currencies as needed

  # Active Storage for photo (optional)
  has_one_attached :photo

  # Set default values
  after_initialize :set_default_values, if: :new_record?

  private

  def set_default_values
    self.language ||= "pt-BR"
    self.time_zone ||= "Brasilia"
    self.currency ||= "BRL"
  end
end

