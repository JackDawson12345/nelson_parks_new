class Admin::LatePaymentsController < Admin::BaseController
  helper IconsHelper

  def index
    @parks = Park.order(:name)

    @dates = LatePayment
               .where.not(due_date: nil)
               .group("DATE_TRUNC('month', due_date)")
               .order(Arel.sql("DATE_TRUNC('month', due_date) DESC"))
               .pluck(Arel.sql("DATE_TRUNC('month', due_date)"))
               .map { |date| date.to_date.strftime("%B %Y") }

    current_month = Time.current.strftime("%B %Y")
    @dates << current_month unless @dates.include?(current_month)

    @pitches = Pitch
                 .includes(:park, :user)
                 .references(:parks)
                 .order("parks.name ASC", :pitch_number)

    @late_payment = LatePayment.new

    @selected_park = params[:park]
    @selected_month = params[:month].presence || current_month

    date = Date.strptime(@selected_month, "%B %Y")

    late_payments = LatePayment
                      .includes(:park, :pitch, :user)
                      .where(due_date: date.beginning_of_month...date.next_month.beginning_of_month)

    late_payments = late_payments.where(park_id: @selected_park) if @selected_park.present?

    @late_payments = late_payments
                       .order("due_date ASC", "parks.name ASC", "pitches.pitch_number ASC")
                       .references(:parks, :pitches)
                       .paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @late_payment = LatePayment.new(late_payment_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @late_payment.save
      redirect_to admin_late_payments_path, notice: "Late payment added"
    else
      redirect_to admin_late_payments_path, alert: @late_payment.errors.full_messages.to_sentence
    end
  end

  def update
    @late_payment = LatePayment.find(params[:id])
    @late_payment.assign_attributes(late_payment_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @late_payment.save
      redirect_to admin_late_payments_path, notice: "Late payment updated"
    else
      redirect_to admin_late_payments_path, alert: @late_payment.errors.full_messages.to_sentence
    end
  end

  def destroy
    late_payment = LatePayment.find(params[:id])
    late_payment.destroy

    redirect_to admin_late_payments_path, notice: "Late payment deleted"
  end

  private

  def late_payment_params
    params.require(:late_payment).permit(
      :pitch_id,
      :due_date,
      :vat,
      :net_total
    )
  end

  def assign_pitch_details
    pitch = Pitch.includes(:park, :user).find(@late_payment.pitch_id)

    @late_payment.park = pitch.park
    @late_payment.user = pitch.user
  end

  def assign_vat
    @late_payment.vat =
      if params[:vat_select] == "custom"
        params[:custom_vat]
      else
        params[:vat_select]
      end
  end

  def calculate_totals
    net_total = @late_payment.net_total.to_d

    @late_payment.net_total = net_total

    vat_rate = @late_payment.vat.to_d

    @late_payment.vat_total = net_total * (vat_rate / 100)
    @late_payment.total = net_total + @late_payment.vat_total
  end
end