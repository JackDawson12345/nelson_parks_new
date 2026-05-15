namespace :invoices do
  desc "Pull Gas & Electric Invoices"
  task gas_and_electric: :environment do
    creds = {
      client_id: '91D9F5664BBF4B9C9CDD0FF60FD7C5E7',
      client_secret: 'nNqkHzQA1mvPtYWBpk5r263sJUQhNtJY5iWNpg_NzmkPI2eH',
      grant_type: 'client_credentials'
    }

    xero_client = XeroRuby::ApiClient.new(credentials: creds)
    xero_client.get_client_credentials_token
    tenant_id = xero_client.last_connection['tenantId']

    cutoff_date = 3.months.ago.beginning_of_month.to_date

    users = User.where(admin: false).where.not(xero_id: [nil, ""])

    users.find_each do |user|
      contact_id = user.xero_id
      user_id = user.id
      pitch_id = Pitch.find_by(user_id: user.id).id

      invoices = fetch_xero_invoices_with_retry(
        xero_client,
        tenant_id,
        contact_id
      )

      invoices = invoices.select do |invoice|
        invoice.date.present? &&
          invoice.date.to_date >= cutoff_date
      end

      invoices.each do |invoice|
        invoice_number_id = invoice.invoice_number.gsub('INV-', '').to_i

        local_invoice = Invoice.find_or_initialize_by(id: invoice_number_id)

        local_invoice.assign_attributes(
          user_id: user.id,
          pitch_id: pitch_id,
          invoice_id: invoice.invoice_id,
          status: invoice.status,
          total: invoice.total,
          amount_due: invoice.amount_due,
          amount_paid: invoice.amount_paid,
          due_date:  invoice.due_date.to_datetime,
          reference: invoice.reference
        )

        local_invoice.save!

        puts "Saved invoice #{invoice.invoice_number} for #{user.full_name}"
      end

      # puts "#{user.full_name} - #{invoices.count} invoices"

      sleep 1
    rescue StandardError => e
      puts "#{user.full_name} failed: #{e.class} - #{e.message}"
      Rails.logger.error("Xero invoice pull failed for user #{user.id}: #{e.class} - #{e.message}")
      next
    end
  end

  def fetch_xero_invoices_with_retry(xero_client, tenant_id, contact_id)
    retries = 0

    begin
      xero_client.accounting_api.get_invoices(
        tenant_id,
        contact_i_ds: [contact_id],
        statuses: %w[AUTHORISED PAID]
      ).invoices || []
    rescue XeroRuby::ApiError => e
      if e.code == 429 && retries < 5
        retry_after = e.response_headers["retry-after"].to_i
        retry_after = 30 if retry_after <= 0

        puts "Xero rate limit hit. Waiting #{retry_after} seconds..."

        sleep retry_after
        retries += 1
        retry
      end

      raise e
    end
  end
end