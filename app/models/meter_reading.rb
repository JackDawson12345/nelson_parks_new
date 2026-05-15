class MeterReading < ApplicationRecord
  belongs_to :user
  belongs_to :pitch

  def electric_price
    byebug
  end

  def gas_price

  end
end
