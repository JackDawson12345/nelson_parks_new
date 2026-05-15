class InvoicesJob
  include Sidekiq::Job

  def perform(invoice_batch_id)
    invoice_batch = InvoiceBatch.find_by(id: invoice_batch_id)
    return unless invoice_batch

    invoice_batch.update!(status: "Uploading")

    utility = invoice_batch.utility
    readings = invoice_batch.reading || []

    if utility == "Gas"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        park = Park.find(reading["park_id"])
        due_date = invoice_batch.due_date

        cost = invoice_batch.calculate_gas_cost(reading, park.id)

        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          "Gas: #{reading['opening_reading']} - #{reading['closing_reading']} (Reading: #{reading['start_date']} - #{reading['end_date']})",
          "Monthly Gas Fee"
        )
      end

    elsif utility == "Electric"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        park = Park.find(reading["park_id"])
        due_date = invoice_batch.due_date

        cost = invoice_batch.calculate_electric_cost(reading, park.id)

        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          "Electric: #{reading['opening_reading']} - #{reading['closing_reading']} (Reading: #{reading['start_date']} - #{reading['end_date']})",
          "Monthly Electric Fee"
        )
      end
    elsif utility == "Pitch Fees"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        due_date = invoice_batch.due_date
        frequency = reading['frequency']

        cost = invoice_batch.calculate_pitch_fees_utilities_cost(reading)

        if frequency == 'Monthly'
          reference = "Pitch Fees - Monthly"
        else
          reference = "Pitch Fees"
        end


        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          reference,
          reference
        )
      end
    elsif utility == "Utilities"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        due_date = invoice_batch.due_date
        frequency = reading['frequency']

        cost = invoice_batch.calculate_pitch_fees_utilities_cost(reading)

        if frequency == 'Monthly'
          reference = "Utilities - Monthly"
        else
          reference = "Utilities"
        end


        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          reference,
          reference
        )
      end
    elsif utility == "Lodge Payments"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        due_date = invoice_batch.due_date
        frequency = reading['frequency']

        cost = invoice_batch.calculate_pitch_fees_utilities_cost(reading)

        if frequency == 'Monthly'
          reference = "Lodge Payments - Monthly"
        else
          reference = "Lodge Payments"
        end


        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          reference,
          reference
        )
      end
    elsif utility == "Late Payments"
      readings.each do |reading|
        user = User.find(reading["user_id"])
        due_date = invoice_batch.due_date

        cost = reading['total'].to_f

        invoice_batch.create_xero_invoice(
          user.xero_id,
          cost,
          due_date,
          'Late Payments',
          'Late Payments'
        )
      end
    end

    invoice_batch.update!(status: "Uploaded")
  rescue => e
    invoice_batch&.update!(status: "Failed")
    raise e
  end
end