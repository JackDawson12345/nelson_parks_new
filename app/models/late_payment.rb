class LatePayment < ApplicationRecord
  belongs_to :pitch
  belongs_to :park
  belongs_to :user

  validates :pitch, :park, :user, :due_date, :vat, :net_total, presence: true
end