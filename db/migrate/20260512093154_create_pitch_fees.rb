class CreatePitchFees < ActiveRecord::Migration[7.2]
  def change
    create_table :pitch_fees do |t|
      t.references :pitch, null: false, foreign_key: true
      t.references :park, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.string :frequency
      t.decimal :vat, precision: 10, scale: 2
      t.decimal :net_total, precision: 10, scale: 2
      t.decimal :vat_total, precision: 10, scale: 2
      t.decimal :total, precision: 10, scale: 2

      t.timestamps
    end
  end
end
