class Admin::MeterReadingsController < Admin::BaseController

  helper IconsHelper

  def index
    @parks = Park.order(:name)

    @dates = MeterReading
               .group("DATE_TRUNC('month', created_at)")
               .order(Arel.sql("DATE_TRUNC('month', created_at) DESC"))
               .pluck(Arel.sql("DATE_TRUNC('month', created_at)"))
               .map { |date| date.strftime("%B %Y") }

    @selected_park    = params[:park]
    @selected_utility = params[:utility]
    @selected_month   = params[:month]

    if @selected_month.present?
      date = Date.strptime(@selected_month, "%B-%Y")
    else
      date = Time.current.to_date
    end

    @current_month_selected =
      date.month == Time.current.month &&
      date.year == Time.current.year

    readings = MeterReading
                 .includes(:user, pitch: :park)
                 .where(created_at: date.beginning_of_month...date.beginning_of_month.next_month)

    if @selected_park.present?
      readings = readings
                   .joins(:pitch)
                   .where(pitches: { park_id: @selected_park })
    end

    if @selected_utility.present?
      readings = readings.where(utility: @selected_utility)
    end

    @thisMonthsReadings = readings
                            .order(:pitch_id)
                            .paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update

    @reading = MeterReading.find(params[:id])

    unless current_month_reading?(@reading)
      head :forbidden
      return
    end

    @reading.assign_attributes(meter_reading_params)

    if @reading.opening_reading.present? && @reading.closing_reading.present?
      @reading.consumption = @reading.closing_reading - @reading.opening_reading
    else
      @reading.consumption = nil
    end

    @reading.save!

    flash.now[:notice] = "Meter reading updated"

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to admin_meter_readings_path,
                    notice: "Meter reading updated"
      end
    end
  end

  private

  def meter_reading_params
    params.require(:meter_reading).permit(
      :start_date,
      :end_date,
      :opening_reading,
      :closing_reading
    )
  end

  def current_month_reading?(reading)
    reading.created_at.month == Time.current.month &&
      reading.created_at.year == Time.current.year
  end
end