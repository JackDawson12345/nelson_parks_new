class Admin::LodgePaymentsController < Admin::BaseController
  helper IconsHelper

  def index
    @parks = Park.order(:name)
    @years = LodgePayment.distinct.order(year: :desc).pluck(:year)
    @years << Date.current.year unless @years.include?(Date.current.year)

    @pitches = Pitch
                 .includes(:park, :user)
                 .references(:parks)
                 .order("parks.name ASC", :pitch_number)

    @lodge_payment = LodgePayment.new

    @selected_park = params[:park]
    @selected_year = params[:year].presence || Date.current.year.to_s

    lodge_payments = LodgePayment
                       .includes(:park, :pitch, :user)
                       .where(year: @selected_year)

    lodge_payments = lodge_payments.where(park_id: @selected_park) if @selected_park.present?

    @lodge_payments = lodge_payments
                        .order("parks.name ASC", "pitches.pitch_number ASC")
                        .references(:parks, :pitches)
                        .paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @lodge_payment = LodgePayment.new(lodge_payment_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @lodge_payment.save
      redirect_to admin_lodge_payments_path, notice: "Lodge payment added"
    else
      redirect_to admin_lodge_payments_path, alert: @lodge_payment.errors.full_messages.to_sentence
    end
  end

  def update
    @lodge_payment = LodgePayment.find(params[:id])
    @lodge_payment.assign_attributes(lodge_payment_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @lodge_payment.save
      redirect_to admin_lodge_payments_path, notice: "Lodge payment updated"
    else
      redirect_to admin_lodge_payments_path, alert: @lodge_payment.errors.full_messages.to_sentence
    end
  end

  def destroy
    lodge_payment = LodgePayment.find(params[:id])
    lodge_payment.destroy

    redirect_to admin_lodge_payments_path, notice: "Lodge payment deleted"
  end

  private

  def lodge_payment_params
    params.require(:lodge_payment).permit(
      :pitch_id,
      :year,
      :frequency,
      :vat,
      :net_total
    )
  end

  def assign_pitch_details
    pitch = Pitch.includes(:park, :user).find(@lodge_payment.pitch_id)

    @lodge_payment.park = pitch.park
    @lodge_payment.user = pitch.user
  end

  def assign_vat
    @lodge_payment.vat =
      if params[:vat_select] == "custom"
        params[:custom_vat]
      else
        params[:vat_select]
      end
  end

  def calculate_totals
    net_total = @lodge_payment.net_total.to_d

    if @lodge_payment.frequency == "Monthly"
      net_total += net_total * 0.15
    end

    @lodge_payment.net_total = net_total

    vat_rate = @lodge_payment.vat.to_d

    @lodge_payment.vat_total = net_total * (vat_rate / 100)
    @lodge_payment.total = net_total + @lodge_payment.vat_total
  end
end