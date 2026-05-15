class Admin::UtilitiesController < Admin::BaseController
  helper IconsHelper

  def index
    @parks = Park.order(:name)
    @years = Utility.distinct.order(year: :desc).pluck(:year)
    @years << Date.current.year unless @years.include?(Date.current.year)

    @pitches = Pitch
                 .includes(:park, :user)
                 .references(:parks)
                 .order("parks.name ASC", :pitch_number)

    @utility = Utility.new

    @selected_park = params[:park]
    @selected_year = params[:year].presence || Date.current.year.to_s

    utilities = Utility
                  .includes(:park, :pitch, :user)
                  .where(year: @selected_year)

    utilities = utilities.where(park_id: @selected_park) if @selected_park.present?

    @utilities = utilities
                   .order("parks.name ASC", "pitches.pitch_number ASC")
                   .references(:parks, :pitches)
                   .paginate(page: params[:page], per_page: 50)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @utility = Utility.new(utility_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @utility.save
      redirect_to admin_utilities_path, notice: "Utility added"
    else
      redirect_to admin_utilities_path, alert: @utility.errors.full_messages.to_sentence
    end
  end

  def update
    @utility = Utility.find(params[:id])
    @utility.assign_attributes(utility_params)

    assign_pitch_details
    assign_vat
    calculate_totals

    if @utility.save
      redirect_to admin_utilities_path, notice: "Utility updated"
    else
      redirect_to admin_utilities_path, alert: @utility.errors.full_messages.to_sentence
    end
  end

  def destroy
    utility = Utility.find(params[:id])
    utility.destroy

    redirect_to admin_utilities_path, notice: "Utility deleted"
  end

  private

  def utility_params
    params.require(:utility).permit(
      :pitch_id,
      :year,
      :frequency,
      :vat,
      :net_total
    )
  end

  def assign_pitch_details
    pitch = Pitch.includes(:park, :user).find(@utility.pitch_id)

    @utility.park = pitch.park
    @utility.user = pitch.user
  end

  def assign_vat
    @utility.vat =
      if params[:vat_select] == "custom"
        params[:custom_vat]
      else
        params[:vat_select]
      end
  end

  def calculate_totals
    net_total = @utility.net_total.to_d

    if @utility.frequency == "Monthly"
      net_total += net_total * 0.15
    end

    @utility.net_total = net_total

    vat_rate = @utility.vat.to_d

    @utility.vat_total = net_total * (vat_rate / 100)
    @utility.total = net_total + @utility.vat_total
  end
end