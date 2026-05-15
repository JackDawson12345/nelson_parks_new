# app/models/invoice.rb
class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :pitch
  has_one :park, through: :pitch

  def reference_type
    case reference.to_s
    when /Gas:/
      'Gas'
    when /Electric:/
      'Electric'
    when /Utilities/
      'Utilities'
    when /Pitch Fee/
      'Pitch Fee'
    when /Late Payment/
      'Late Payment'
    when /Lodge Payment/
      'Lodge Payment'
    end
  end

  def invoice_type
    ref = reference.to_s.downcase

    return :gas if ref.include?("gas")
    return :electric if ref.include?("electric")
    return :pitch_fees if ref.include?("pitch fee")
    return :utilities if ref.include?("utilities")
    return :late_payments if ref.include?("late payments")
    return :lodge_payments if ref.include?("lodge payments")

    :other
  end

  def reading_rows
    case invoice_type
    when :electric

      from_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[0]
      to_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[1]
      previous_reading = reference.split(' (')[0].gsub('Electric: ', '').split(' - ')[0]
      current_reading = reference.split(' (')[0].gsub('Electric: ', '').split(' - ')[1]
      usage = current_reading.to_f - previous_reading.to_f
      billing_days = (to_date.to_date - from_date.to_date).to_i

      [
        ["Date of Readings", "Units Used"],
        ["Previous Meter Readings taken on the: #{from_date.to_date.strftime('%d/%m/%Y')}", previous_reading],
        ["Present Meter Reading Taken on the: #{to_date.to_date.strftime('%d/%m/%Y')}", current_reading],
        ["Total Units Used In #{billing_days} Days", usage.to_s]
      ]

    when :gas
      from_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[0]
      to_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[1]
      previous_reading = reference.split(' (')[0].gsub('Gas: ', '').split(' - ')[0]
      current_reading = reference.split(' (')[0].gsub('Gas: ', '').split(' - ')[1]
      usage = current_reading.to_f - previous_reading.to_f
      billing_days = (to_date.to_date - from_date.to_date).to_i

      [
        ["Date of Readings", "Units Used"],
        ["Previous Gas Reading: #{from_date.to_date.strftime('%d/%m/%Y')}", previous_reading],
        ["Present Gas Reading: #{to_date.to_date.strftime('%d/%m/%Y')}", current_reading],
        ["Total Gas Units Used In #{billing_days} Days", usage.to_s]
      ]

    else
      []
    end
  end

  def charge_rows
    case invoice_type
    when :electric
      from_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[0]
      to_date = reference.split('(')[1].gsub('Reading: ', '').gsub(')', '').split(' - ')[1]
      billing_days = (to_date.to_date - from_date.to_date).to_i

      previous_reading = reference.split(' (')[0].gsub('Electric: ', '').split(' - ')[0]
      current_reading = reference.split(' (')[0].gsub('Electric: ', '').split(' - ')[1]
      usage = current_reading.to_f - previous_reading.to_f
      rates = UtilityRate.find_by(park_id: user.pitch.park.id, utility: 'electric')
      units_used = (rates.unit_rate * usage).round(2)
      standard_charge = (rates.standing_rate * billing_days).round(2)
      unit_standing_charge_vat = ((units_used + standard_charge).round(2) * 0.2).round(2)


      [
        ["Charge Description", "Amount"],
        ["Units Used @ " + rates.unit_rate.to_s +  " Per Unit", money(units_used)],
        ["Standing Charge @ £0.00400 Per Day", money(standard_charge)],
        ["Unit & Standing Charge VAT @ 20%", money(unit_standing_charge_vat)],
        ["Maintenance & Admin Charge", "£11.42"],
        ["Maintenance & Admin Charge VAT @ 20%", "£2.28"],
        ["Total Amount to be Paid for this Month", money(total)],
        ["Amount Outstanding", money(amount_due)]
      ]

    when :gas
      previous_reading = reference.split(' (')[0].gsub('Gas: ', '').split(' - ')[0]
      current_reading = reference.split(' (')[0].gsub('Gas: ', '').split(' - ')[1]
      usage = current_reading.to_f - previous_reading.to_f
      rates = UtilityRate.find_by(park_id: user.pitch.park.id, utility: 'gas')
      litres_used = (3.85 * usage).round(2)
      units_charge = (litres_used * rates.unit_rate).round(2)
      vat = ((units_charge + 11.67).round(2) * 0.2).round(2)

      [
        ["Charge Description","Amount"],
        ['Litres Used (1m3 = 3.85 Litres)', litres_used.to_s],
        ['Charge Per Litre', '£' + rates.unit_rate.to_s],
        ['Units Charge @ £' + rates.unit_rate.to_s + ' Per Unit', money(units_charge)],
        ['Admin / Maint, Tank & Meter Rental Charge', '£11.67'],
        ['VAT @ 20%', money(vat)],
        ['Total Amount to be Paid for this Month', money(total)],
        ['Amount Outstanding', money(amount_due)]
      ]

    when :pitch_fees
      [
        ["<font size='10'>Item Code</font>", "<font size='10'>Description</font>", "<font size='10'>Quantity</font>", "<font size='10'>Unit Price</font>", "<font size='10'>Tax Rate</font>", "<font size='10'>Amount GBP</font>"],
        ['' , "<font size='10'>" + reference + "</font>", "<font size='10'>1.00</font>", "<font size='10'>" + money(total) + "</font>", "<font size='10'>NO VAT</font>", "<font size='10'>" + money(total) + "</font>"],
        ["" , "", "", "", "<font size='10'><b>Amount Outstanding</b></font>", "<font size='10'><b>" + money(amount_due) + "</b></font>"]
      ]
    when :utilities
      [
        ["<font size='10'>Item Code</font>", "<font size='10'>Description</font>", "<font size='10'>Quantity</font>", "<font size='10'>Unit Price</font>", "<font size='10'>Tax Rate</font>", "<font size='10'>Amount GBP</font>"],
        ['' , "<font size='10'>" + reference + "</font>", "<font size='10'>1.00</font>", "<font size='10'>" + money(total) + "</font>", "<font size='10'>NO VAT</font>", "<font size='10'>" + money(total) + "</font>"],
        ["" , "", "", "", "<font size='10'><b>Amount Outstanding</b></font>", "<font size='10'><b>" + money(amount_due) + "</b></font>"]
      ]
    when :late_payments
      [
        ["<font size='10'>Item Code</font>", "<font size='10'>Description</font>", "<font size='10'>Quantity</font>", "<font size='10'>Unit Price</font>", "<font size='10'>Tax Rate</font>", "<font size='10'>Amount GBP</font>"],
        ['' , "<font size='10'>" + reference + "</font>", "<font size='10'>1.00</font>", "<font size='10'>" + money(total) + "</font>", "<font size='10'>NO VAT</font>", "<font size='10'>" + money(total) + "</font>"],
        ["" , "", "", "", "<font size='10'><b>Amount Outstanding</b></font>", "<font size='10'><b>" + money(amount_due) + "</b></font>"]
      ]
    when :lodge_payments
      [
        ["<font size='10'>Item Code</font>", "<font size='10'>Description</font>", "<font size='10'>Quantity</font>", "<font size='10'>Unit Price</font>", "<font size='10'>Tax Rate</font>", "<font size='10'>Amount GBP</font>"],
        ['' , "<font size='10'>" + reference + "</font>", "<font size='10'>1.00</font>", "<font size='10'>" + money(total) + "</font>", "<font size='10'>NO VAT</font>", "<font size='10'>" + money(total) + "</font>"],
        ["" , "", "", "", "<font size='10'><b>Amount Outstanding</b></font>", "<font size='10'><b>" + money(amount_due) + "</b></font>"]
      ]
    else
      [
        ["<font size='10'>Item Code</font>", "<font size='10'>Description</font>", "<font size='10'>Quantity</font>", "<font size='10'>Unit Price</font>", "<font size='10'>Tax Rate</font>", "<font size='10'>Amount GBP</font>"],
        ['' , "<font size='10'>" + reference + "</font>", "<font size='10'>1.00</font>", "<font size='10'>" + money(total) + "</font>", "<font size='10'>NO VAT</font>", "<font size='10'>" + money(total) + "</font>"],
        ["" , "", "", "", "<font size='10'><b>Amount Outstanding</b></font>", "<font size='10'><b>" + money(amount_due) + "</b></font>"]
      ]
    end
  end

  private

  def money(amount)
    "£#{format('%.2f', amount.to_f)}"
  end
end