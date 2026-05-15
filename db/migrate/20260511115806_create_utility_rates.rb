class CreateUtilityRates < ActiveRecord::Migration[7.2]
  def change
    create_table :utility_rates do |t|
      t.references :park, null: false, foreign_key: true
      t.string :utility
      t.decimal :unit_rate, precision: 10, scale: 4
      t.decimal :standing_rate, precision: 10, scale: 2
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
