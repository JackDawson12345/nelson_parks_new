class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :pitch, dependent: :nullify

  validates :full_name, presence: true, unless: :admin?
  validates :email, presence: true

  has_many :notifications
end
