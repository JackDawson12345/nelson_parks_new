class InvoiceBatch < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :park

  after_update_commit :broadcast_status_update, if: :saved_change_to_status?

  validates :start_date,
            :end_date,
            :invoice_date,
            :due_date,
            presence: true

  def self.calculate_reading_cost(reading)
    if reading.utility == 'Gas'
      consumption = reading.consumption

      gasLitresUsed = (consumption.to_f * 3.85).round(2)
      gasLitresCost = (gasLitresUsed * UtilityRate.where(park_id: reading.pitch.park_id, utility: 'gas').first.unit_rate).round(2)

      totalCost = (gasLitresCost + 11.67).round(2)
      vat = (totalCost * 0.2).round(2)
      finalCost = (totalCost + vat).round(2)

      finalCost

    elsif reading.utility == 'Electric'
      days = (reading.start_date.to_date..reading.end_date.to_date).count
      consumption = reading.consumption

      electric_units_cost = (consumption * UtilityRate.where(park_id: reading.pitch.park_id, utility: 'electric').first.unit_rate).round(2)
      standing_rate_charge = (days * UtilityRate.where(park_id: reading.pitch.park_id, utility: 'electric').first.standing_rate).round(2)
      total_cost = (electric_units_cost + standing_rate_charge).round(2)
      vat = (total_cost * 0.20).round(2)
      final_cost = (total_cost + vat).round(2)
      total_maintenance_charge = (11.42 + 2.28).round(2)

      totalFinalCost = (final_cost + total_maintenance_charge).round(2)

      totalFinalCost
    end

  end


  def calculate_gas_cost(reading, park_id)
    opening_reading = reading['opening_reading']
    closing_reading = reading['closing_reading']
    usage = reading['consumption'].to_f

    start_date = reading['start_date'].to_datetime
    end_date = reading['end_date'].to_datetime
    billing_days = (end_date.to_date - start_date.to_date).to_i

    rates = UtilityRate.find_by(park_id: park_id, utility: 'gas')

    litres_used = (3.85 * usage).round(2)
    units_charge = (litres_used * rates.unit_rate).round(2)
    vat = ((units_charge + 11.67).round(2) * 0.2).round(2)


    total = (litres_used + units_charge + 11.67 + vat).round(2)
  end

  def calculate_electric_cost(reading, park_id)
    opening_reading = reading['opening_reading']
    closing_reading = reading['closing_reading']
    usage = reading['consumption'].to_f

    start_date = reading['start_date'].to_datetime
    end_date = reading['end_date'].to_datetime
    billing_days = (end_date.to_date - start_date.to_date).to_i

    rates = UtilityRate.find_by(park_id: park_id, utility: 'electric')

    units_used = (rates.unit_rate * usage).round(2)
    standard_charge = (rates.standing_rate * billing_days).round(2)
    unit_standing_charge_vat = ((units_used + standard_charge).round(2) * 0.2).round(2)
    maintenance_fee = (11.42 + 2.28).round(2)

    total = (units_used + standard_charge + unit_standing_charge_vat + maintenance_fee).round(2)
  end

  def calculate_pitch_fees_utilities_cost(reading)
    if reading['frequency'] == 'Monthly'
      total = reading['total'].to_f / 8
    else
      total = reading['total'].to_f
    end
  end




  def create_xero_invoice(user_id, cost, due_date, reference, description)
    require 'xero-ruby'  # Ensure you have the XeroRuby gem loaded

    creds = {
      client_id: '91D9F5664BBF4B9C9CDD0FF60FD7C5E7',
      client_secret: 'nNqkHzQA1mvPtYWBpk5r263sJUQhNtJY5iWNpg_NzmkPI2eH',
      grant_type: 'client_credentials'
    }

    xero_client = XeroRuby::ApiClient.new(credentials: creds)
    token_set = xero_client.get_client_credentials_token

    tenant_id = xero_client.last_connection['tenantId']


    invoices = {
      invoices: [{
                   type: XeroRuby::Accounting::Invoice::ACCREC,
                   contact: { contact_id: user_id },
                   LineAmountTypes: "Inclusive",
                   line_items: [{
                                  description: description,
                                  quantity: 1.0,
                                  unit_amount: cost,
                                  account_code: "202"
                                }],
                   date: Date.today,
                   due_date: due_date,
                   reference: reference,
                   status: XeroRuby::Accounting::Invoice::DRAFT
                 }]
    }

    # Add retry logic for creating invoices
    begin

      response = xero_client.accounting_api.create_invoices(tenant_id, invoices)
      invoice = response.invoices.first
      invoice_user = User.find_by(xero_id: invoice.contact.contact_id)

      Invoice.create(id: invoice.invoice_number.gsub('INV-', '').to_i,
                     user_id: invoice_user.id,
                     pitch_id: Pitch.find_by(user_id: invoice_user.id).id,
                     invoice_id: invoice.invoice_id,
                     status: 'PORTAL CREATED',
                     total: invoice.total,
                     amount_due: invoice.amount_due,
                     amount_paid: invoice.amount_paid,
                     due_date:  invoice.due_date.to_datetime,
                     reference: invoice.reference)

    rescue XeroRuby::ApiError => e
      error_message = e.message

      # Extract status code from the error message
      if error_message =~ /HTTP status code: (\d+)/
        status_code = $1.to_i  # Capture the status code
        if status_code == 429  # Check if the error is a rate limit error
          # Extract 'retry-after' value from the error message
          if error_message =~ /retry-after"=>\"(\d+)\"/
            retry_after = $1.to_i  # Capture the retry-after duration in seconds
            puts "Rate limit exceeded. Retrying after #{retry_after} seconds."
            sleep(retry_after)  # Wait for the specified duration
            retry  # Retry the API call
          else
            puts "Rate limit exceeded, but no retry-after header found."
          end
        end
      end

      # Handle other API errors
      puts "API Error: #{error_message}"
    end

  end

  private

  def broadcast_status_update
    broadcast_replace_to(
      "invoice_batches",
      target: dom_id(self),
      partial: "admin/invoice_batches/invoice_batch",
      locals: { invoice_batch: self }
    )

    broadcast_replace_to(
      "invoice_batches",
      target: "invoice_batch_status_#{id}",
      partial: "admin/invoice_batches/status",
      locals: { invoice_batch: self }
    )

    broadcast_replace_to(
      "invoice_batches",
      target: "invoice_batch_actions_#{id}",
      partial: "admin/invoice_batches/actions",
      locals: { invoice_batch: self }
    )
  end


end
