class Admin::SettingsController < Admin::BaseController
  def show
    load_settings
  end

  def create
    @utility_rate = UtilityRate.new(utility_rate_params)

    if @utility_rate.save
      redirect_to admin_settings_path, notice: "Utility rate saved"
    else
      load_settings
      render :show, status: :unprocessable_entity
    end
  end

  def update_utility_rate
    @utility_rate = UtilityRate.find(params[:id])

    if @utility_rate.update(utility_rate_params)
      redirect_to admin_settings_path, notice: "Utility rate updated"
    else
      load_settings
      render :show, status: :unprocessable_entity
    end
  end

  def destroy_utility_rate
    @utility_rate = UtilityRate.find(params[:id])
    @utility_rate.destroy

    redirect_to admin_settings_path, notice: "Utility rate deleted"
  end

  private

  def load_settings
    @parks = Park.all
    @utility_rate ||= UtilityRate.new
    @utility_rates = UtilityRate.includes(:park).order(created_at: :desc)
  end

  def utility_rate_params
    params.require(:utility_rate).permit(
      :park_id,
      :utility,
      :unit_rate,
      :standing_rate,
      :from_date,
      :to_date
    )
  end
end