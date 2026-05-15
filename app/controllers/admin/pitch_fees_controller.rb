class Admin::PitchFeesController < Admin::BaseController
  helper IconsHelper

  def index
    @parks = Park.order(:name)
    @years = PitchFee.distinct.order(year: :desc).pluck(:year)
    @years << Date.current.year unless @years.include?(Date.current.year)

    @pitches = Pitch
                 .includes(:park, :user)
                 .references(:parks)
                 .order("parks.name ASC", :pitch_number)

    @pitch_fee = PitchFee.new

    @selected_park = params[:park]
    @selected_year = params[:year].presence || Date.current.year.to_s

    pitch_fees = PitchFee
                   .includes(:park, :pitch, :user)
                   .where(year: @selected_year)

    pitch_fees = pitch_fees.where(park_id: @selected_park) if @selected_park.present?

    @pitch_fees = pitch_fees
                    .order("parks.name ASC", "pitches.pitch_number ASC")
                    .references(:parks, :pitches)
                    .paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @pitch_fee = PitchFee.new(pitch_fee_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @pitch_fee.save
      redirect_to admin_pitch_fees_path,
                  notice: "Pitch fee added"
    else
      redirect_to admin_pitch_fees_path,
                  alert: @pitch_fee.errors.full_messages.to_sentence
    end
  end

  def update
    @pitch_fee = PitchFee.find(params[:id])
    @pitch_fee.assign_attributes(pitch_fee_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @pitch_fee.save
      redirect_to admin_pitch_fees_path,
                  notice: "Pitch fee updated"
    else
      redirect_to admin_pitch_fees_path,
                  alert: @pitch_fee.errors.full_messages.to_sentence
    end
  end

  def destroy
    pitch_fee = PitchFee.find(params[:id])
    park_id = pitch_fee.park_id
    year = pitch_fee.year

    pitch_fee.destroy

    redirect_to admin_pitch_fees_path,
                notice: "Pitch fee deleted"
  end

  private

  def pitch_fee_params
    params.require(:pitch_fee).permit(
      :pitch_id,
      :year,
      :frequency,
      :vat,
      :net_total
    )
  end

  def assign_pitch_details
    pitch = Pitch.includes(:park, :user).find(@pitch_fee.pitch_id)

    @pitch_fee.park = pitch.park
    @pitch_fee.user = pitch.user
  end

  def assign_vat
    @pitch_fee.vat =
      if params[:vat_select] == "custom"
        params[:custom_vat]
      else
        params[:vat_select]
      end
  end

  def calculate_totals
    net_total = @pitch_fee.net_total.to_d

    if @pitch_fee.frequency == "Monthly"
      net_total += net_total * 0.15
    end

    @pitch_fee.net_total = net_total

    vat_rate = @pitch_fee.vat.to_d

    @pitch_fee.vat_total = net_total * (vat_rate / 100)
    @pitch_fee.total = net_total + @pitch_fee.vat_total
  end
end