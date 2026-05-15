class ChangeStandingRateScaleInUtilityRates < ActiveRecord::Migration[7.2]
  def change
    change_column :utility_rates, :standing_rate, :decimal, precision: 10, scale: 4
  end
end
