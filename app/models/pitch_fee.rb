class PitchFee < ApplicationRecord
  belongs_to :pitch
  belongs_to :park
  belongs_to :user
end
