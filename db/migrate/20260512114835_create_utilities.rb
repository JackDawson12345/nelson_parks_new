class CreateUtilities < ActiveRecord::Migration[7.2]
  def change
    create_table :utilities do |t|
      t.references :pitch, null: false, foreign_key: true
      t.references :park, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.string :frequency
      t.decimal :vat
      t.decimal :net_total
      t.decimal :vat_total
      t.decimal :total

      t.timestamps
    end
  end
end
