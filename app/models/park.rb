class Park < ApplicationRecord
  has_many :pitches, dependent: :destroy

  validates :name, presence: true
  validates :location, presence: true
end
