class Admin::InvoiceBatchesController < Admin::BaseController
  def index
    @invoice_batches = InvoiceBatch.includes(:park).order(created_at: :desc)
    @invoice_batch = InvoiceBatch.new

    readings = @invoice_batches.flat_map { |invoice_batch| invoice_batch.reading || [] }

    user_ids = readings.map { |reading| reading["user_id"] || reading[:user_id] }.compact
    pitch_ids = readings.map { |reading| reading["pitch_id"] || reading[:pitch_id] }.compact

    @users_by_id = User.where(id: user_ids).index_by(&:id)
    @pitches_by_id = Pitch.where(id: pitch_ids).index_by(&:id)
  end

  def create
    @invoice_batch = InvoiceBatch.new(invoice_batch_params)

    park = Park.find(invoice_batch_params[:park_id].to_i)
    reference = 'BATCH-' + park.name.gsub(' ', '').upcase + '-' + invoice_batch_params[:utility].gsub(' ', '-').upcase + '-' + invoice_batch_params[:start_date].gsub('-', '') + '-' + invoice_batch_params[:end_date].gsub('-', '')

    @invoice_batch.reference = reference
    @invoice_batch.status = 'Draft'

    start_date = Date.parse(invoice_batch_params[:start_date])
    end_date   = Date.parse(invoice_batch_params[:end_date])

    if invoice_batch_params[:utility] == 'Gas' or invoice_batch_params[:utility] == 'Electric'
      meter_readings = MeterReading
                         .joins(:pitch)
                         .where(
                           pitches: { park_id: park.id },
                           utility: invoice_batch_params[:utility]
                         )
                         .where(
                           start_date: start_date..end_date,
                           end_date: start_date..end_date
                         )

      @invoice_batch.reading = meter_readings.map do |reading|
        {
          user_id: reading.user_id,
          pitch_id: reading.pitch_id,
          park_id: park.id,
          utility: reading.utility,
          opening_reading: reading.opening_reading,
          closing_reading: reading.closing_reading,
          consumption: reading.consumption,
          total_price: InvoiceBatch.calculate_reading_cost(reading),
          start_date: reading.start_date,
          end_date: reading.end_date
        }
      end

    elsif invoice_batch_params[:utility] == 'Pitch Fees' or invoice_batch_params[:utility] == 'Utilities' or invoice_batch_params[:utility] == 'Lodge Payments'
      year = start_date.year

      utility = invoice_batch_params[:utility]
      if utility == 'Pitch Fees'
        readings = PitchFee.where(year: year)
      elsif utility == 'Utilities'
        readings = Utility.where(year: year)
      elsif utility == 'Lodge Payments'
        readings = LodgePayment.where(year: year)
      end

      @invoice_batch.reading = readings.map do |readings|
        {
          user_id: readings.user_id,
          pitch_id: readings.pitch_id,
          park_id: park.id,
          year: readings.year,
          frequency: readings.frequency,
          vat: readings.vat.to_d,
          net_total: readings.net_total.to_d,
          vat_total: readings.vat_total.to_d,
          total: readings.total.to_d
        }
      end

    elsif invoice_batch_params[:utility] == 'Late Payments'

      late_payments = LatePayment.where(
                           due_date: start_date..end_date
                         )

      @invoice_batch.reading = late_payments.map do |readings|
        {
          user_id: readings.user_id,
          pitch_id: readings.pitch_id,
          park_id: park.id,
          due_date: readings.due_date,
          vat: readings.vat.to_d,
          net_total: readings.net_total.to_d,
          vat_total: readings.vat_total.to_d,
          total: readings.total.to_d
        }
      end

    end


    if @invoice_batch.save

      Notification.send_notification(
        'Admins',
        invoice_batch_params[:utility] + ' Batch',
        'A new ' + invoice_batch_params[:utility] + ' Batch has been submitted'
      )

      redirect_to admin_invoice_batches_path, notice: "Invoice batch created."
    else
      @invoice_batches = InvoiceBatch.includes(:park).order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice_batch = InvoiceBatch.find(params[:id])
    @invoice_batch.destroy

    redirect_to admin_invoice_batches_path, notice: "Invoice batch deleted."
  end

  def create_invoices
    @invoice_batch = InvoiceBatch.find(params[:id])

    @invoice_batch.update!(status: "Uploading")

    InvoicesJob.perform_async(@invoice_batch.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          @invoice_batch,
          partial: "admin/invoice_batches/invoice_batch",
          locals: { invoice_batch: @invoice_batch }
        )
      end

      format.html do
        redirect_to admin_invoice_batches_path, notice: "Invoices are being created."
      end
    end
  end

  private

  def invoice_batch_params
    params.require(:invoice_batch).permit(
      :park_id,
      :start_date,
      :end_date,
      :invoice_date,
      :due_date,
      :notes,
      :utility
    )
  end
end