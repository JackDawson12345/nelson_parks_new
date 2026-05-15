class Pitch < ApplicationRecord
  belongs_to :park
  belongs_to :user, optional: true

  validates :pitch_number, presence: true
  validates :pitch_type, presence: true
  validates :status, presence: true
  validates :park_id, presence: true
end