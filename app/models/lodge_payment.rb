class LodgePayment < ApplicationRecord
  belongs_to :pitch
  belongs_to :park
  belongs_to :user

  validates :pitch, :park, :user, :year, :frequency, :vat, :net_total, presence: true
end